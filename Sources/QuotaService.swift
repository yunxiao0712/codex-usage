import Foundation

enum QuotaError: LocalizedError {
    case codexNotFound
    case noQuotaWindows
    case noQuotaWindow(QuotaPeriod)
    case timedOut
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .codexNotFound: return "找不到本机 Codex"
        case .noQuotaWindows: return "当前账户暂无可读取的额度"
        case .noQuotaWindow(let period): return "当前账户暂无\(period.title)额度"
        case .timedOut: return "读取超时，稍后自动重试"
        case .malformedResponse: return "Codex 返回了无法识别的数据"
        }
    }
}

final class CodexQuotaService {
    private var process: Process?
    private var stdin: FileHandle?
    private var isRefreshing = false
    private var nextRequestID = 1
    private var pending: [Int: (Result<QuotaSnapshot, Error>) -> Void] = [:]
    private var buffer = Data()
    private let queue = DispatchQueue(label: "app.codexusagestrip.codex-service")

    func refresh(completion: @escaping (Result<QuotaSnapshot, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            if self.isRefreshing { return }
            self.isRefreshing = true
            do {
                try self.ensureServer()
                let id = self.nextRequestID
                self.nextRequestID += 1
                self.pending[id] = completion
                try self.send(["method": "account/rateLimits/read", "id": id])
                self.queue.asyncAfter(deadline: .now() + 12) { [weak self] in
                    guard let self, let callback = self.pending.removeValue(forKey: id) else { return }
                    self.isRefreshing = false
                    DispatchQueue.main.async { callback(.failure(QuotaError.timedOut)) }
                }
            } catch {
                self.isRefreshing = false
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    func stop() {
        queue.sync {
            process?.terminate()
            process = nil
            stdin = nil
            pending.removeAll()
            buffer.removeAll()
        }
    }

    private func ensureServer() throws {
        if let process, process.isRunning { return }
        guard let codexPath = Self.resolveCodexPath() else { throw QuotaError.codexNotFound }

        let newProcess = Process()
        let stdout = Pipe()
        let input = Pipe()
        newProcess.executableURL = URL(fileURLWithPath: codexPath)
        newProcess.arguments = ["app-server", "--stdio"]
        newProcess.standardOutput = stdout
        newProcess.standardInput = input
        newProcess.standardError = FileHandle.nullDevice

        stdout.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            self?.queue.async { self?.consume(data) }
        }

        newProcess.terminationHandler = { [weak self] _ in
            self?.queue.async {
                self?.process = nil
                self?.stdin = nil
            }
        }

        try newProcess.run()
        process = newProcess
        stdin = input.fileHandleForWriting
        try send([
            "method": "initialize",
            "id": 0,
            "params": [
                "clientInfo": [
                    "name": "codex_usage_strip",
                    "title": "Codex Usage Strip",
                    "version": AppInfo.version
                ]
            ]
        ])
        try send(["method": "initialized", "params": [:] as [String: Any]])
    }

    private func send(_ object: [String: Any]) throws {
        guard let stdin else { throw QuotaError.codexNotFound }
        let data = try JSONSerialization.data(withJSONObject: object)
        stdin.write(data)
        stdin.write(Data([0x0A]))
    }

    private func consume(_ data: Data) {
        buffer.append(data)
        while let newline = buffer.firstIndex(of: 0x0A) {
            let line = buffer.prefix(upTo: newline)
            buffer.removeSubrange(...newline)
            guard !line.isEmpty,
                  let object = try? JSONSerialization.jsonObject(with: Data(line)) as? [String: Any] else {
                continue
            }
            if let id = (object["id"] as? NSNumber)?.intValue,
               id > 0,
               let callback = pending.removeValue(forKey: id) {
                isRefreshing = false
                let result: Result<QuotaSnapshot, Error>
                if let snapshot = Self.parseQuotaSnapshot(from: object) {
                    result = .success(snapshot)
                } else {
                    result = .failure(QuotaError.noQuotaWindows)
                }
                DispatchQueue.main.async { callback(result) }
            }
        }
    }

    static func resolveCodexPath(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        home: String = NSHomeDirectory(),
        isExecutable: (String) -> Bool = { FileManager.default.isExecutableFile(atPath: $0) }
    ) -> String? {
        // App bundle layouts are compatibility fallbacks, not stable public paths.
        let bundledCandidates = ["/Applications", "\(home)/Applications"].flatMap { directory in
            ["ChatGPT.app", "Codex.app"].flatMap { app in
                [
                    "\(directory)/\(app)/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex",
                    "\(directory)/\(app)/Contents/Resources/codex",
                    "\(directory)/\(app)/Contents/Resources/codex-cli/bin/codex"
                ]
            }
        }
        let cliCandidates = [
            "/opt/homebrew/bin/codex",
            "/usr/local/bin/codex",
            "\(home)/.local/bin/codex"
        ]
        let pathCandidates = (environment["PATH"] ?? "").split(separator: ":")
            .filter { $0.hasPrefix("/") }
            .map { "\($0)/codex" }
        let candidates = [environment["CODEX_PATH"]].compactMap { $0 }
            + bundledCandidates + cliCandidates + pathCandidates
        return candidates.first { !$0.isEmpty && isExecutable($0) }
    }

    static func parseQuotaSnapshot(from object: [String: Any]) -> QuotaSnapshot? {
        guard let result = object["result"] as? [String: Any] else { return nil }

        let direct = result["rateLimits"] as? [String: Any]
        let directID = direct?["limitId"] as? String
        let totalLimit: [String: Any]?
        if let direct, directID == nil || directID == "codex" {
            totalLimit = direct
        } else if let byID = result["rateLimitsByLimitId"] as? [String: Any] {
            totalLimit = byID["codex"] as? [String: Any]
        } else {
            totalLimit = nil
        }

        guard let totalLimit else { return nil }
        let windows = ["primary", "secondary"].compactMap { totalLimit[$0] as? [String: Any] }
        var parsed: [QuotaPeriod: QuotaWindow] = [:]
        let now = Date()
        for window in windows {
            guard let used = (window["usedPercent"] as? NSNumber)?.doubleValue,
                  let resetTimestamp = (window["resetsAt"] as? NSNumber)?.doubleValue,
                  let duration = (window["windowDurationMins"] as? NSNumber)?.doubleValue,
                  used.isFinite, resetTimestamp.isFinite, duration.isFinite,
                  let period = QuotaPeriod.allCases.first(where: { $0.matches(duration: duration) })
            else { continue }
            if let previous = parsed[period], previous.windowDurationMins > duration { continue }
            parsed[period] = QuotaWindow(
                usedPercent: min(max(used, 0), 100),
                resetsAt: Date(timeIntervalSince1970: resetTimestamp),
                windowDurationMins: duration,
                updatedAt: now
            )
        }
        return parsed.isEmpty ? nil : QuotaSnapshot(windows: parsed)
    }
}
