import Foundation
import ServiceManagement

final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()

    var isEnabled: Bool {
        switch SMAppService.mainApp.status {
        case .enabled, .requiresApproval:
            return true
        default:
            return FileManager.default.fileExists(atPath: fallbackPlist.path)
        }
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            do {
                if SMAppService.mainApp.status == .notRegistered {
                    try SMAppService.mainApp.register()
                }
                if isEnabled { return }
            } catch {
                // Local ad-hoc builds can be rejected by SMAppService. The per-user
                // LaunchAgent below is the deterministic fallback for those builds.
            }
            try writeFallbackLaunchAgent()
        } else {
            if SMAppService.mainApp.status == .enabled || SMAppService.mainApp.status == .requiresApproval {
                try? SMAppService.mainApp.unregister()
            }
            if FileManager.default.fileExists(atPath: fallbackPlist.path) {
                try FileManager.default.removeItem(at: fallbackPlist)
            }
        }
    }

    private var fallbackPlist: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/app.quotaglow.desktop.plist")
    }

    private func writeFallbackLaunchAgent() throws {
        let executable = Bundle.main.bundleURL
            .appendingPathComponent("Contents/MacOS/QuotaGlow")
            .path
        let payload: [String: Any] = [
            "Label": "app.quotaglow.desktop",
            "ProgramArguments": [executable],
            "RunAtLoad": true,
            "KeepAlive": false,
            "ProcessType": "Interactive",
            "LimitLoadToSessionType": "Aqua"
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: payload, format: .xml, options: 0)
        let directory = fallbackPlist.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: fallbackPlist, options: .atomic)
    }

    private init() {}
}
