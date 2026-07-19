import AppKit

enum AppIconExporter {
    static func exportPNG(to url: URL) throws {
        let pixels = 1024
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixels,
            pixelsHigh: pixels,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { throw CocoaError(.fileWriteUnknown) }

        let previousContext = NSGraphicsContext.current
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        defer { NSGraphicsContext.current = previousContext }

        NSColor.clear.setFill()
        NSRect(x: 0, y: 0, width: pixels, height: pixels).fill()

        let outer = NSBezierPath(roundedRect: NSRect(x: 72, y: 72, width: 880, height: 880), xRadius: 224, yRadius: 224)
        NSGradient(colors: [NSColor(hex: "30343B"), NSColor(hex: "0D0F12")])?.draw(in: outer, angle: 90)
        NSColor(hex: "FFFFFF28").setStroke()
        outer.lineWidth = 8
        outer.stroke()

        let trackRect = NSRect(x: 220, y: 452, width: 584, height: 120)
        let track = NSBezierPath(roundedRect: trackRect, xRadius: 60, yRadius: 60)
        NSColor(hex: "FFFFFF22").setFill()
        track.fill()

        let fillRect = NSRect(x: 220, y: 452, width: 390, height: 120)
        let fill = NSBezierPath(roundedRect: fillRect, xRadius: 60, yRadius: 60)
        NSColor(hex: "68DDB1").setFill()
        fill.fill()
        NSColor(hex: "68DDB166").setStroke()
        fill.lineWidth = 30
        fill.stroke()

        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: url, options: .atomic)
    }
}

final class QuotaGlowLogoView: NSView {
    override var intrinsicContentSize: NSSize { NSSize(width: 76, height: 76) }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let rect = bounds.insetBy(dx: 2, dy: 2)
        let background = NSBezierPath(roundedRect: rect, xRadius: 22, yRadius: 22)
        NSGradient(colors: [NSColor(hex: "24262B"), NSColor(hex: "101114")])?.draw(in: background, angle: 90)
        NSColor(hex: "FFFFFF24").setStroke()
        background.lineWidth = 1
        background.stroke()

        let trackRect = NSRect(x: 15, y: 33, width: 46, height: 10)
        let track = NSBezierPath(roundedRect: trackRect, xRadius: 5, yRadius: 5)
        NSColor(hex: "FFFFFF24").setFill()
        track.fill()
        let fill = NSBezierPath(roundedRect: NSRect(x: 15, y: 33, width: 31, height: 10), xRadius: 5, yRadius: 5)
        NSColor(hex: "68DDB1").setFill()
        fill.fill()
        NSColor(hex: "68DDB1").withAlphaComponent(0.35).setStroke()
        fill.lineWidth = 4
        fill.stroke()
    }
}

final class AboutWindowController: NSWindowController {
    var onCheckForUpdates: (() -> Void)?
    private let updateStatus = NSTextField(labelWithString: "")
    private let checkButton = NSButton()

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 390),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "关于 QuotaGlow"
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)
        buildUI()
    }

    required init?(coder: NSCoder) { nil }

    func present() {
        refreshUpdateStatus()
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func setChecking() {
        checkButton.isEnabled = false
        checkButton.title = "正在检查…"
        updateStatus.stringValue = "正在读取更新清单"
    }

    func setUpdateResult(_ text: String) {
        checkButton.isEnabled = true
        checkButton.title = "检查更新…"
        updateStatus.stringValue = text
    }

    private func buildUI() {
        guard let content = window?.contentView else { return }
        let logo = QuotaGlowLogoView()
        logo.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "QuotaGlow")
        title.font = NSFont(name: "Avenir Next Demi Bold", size: 28) ?? NSFont.systemFont(ofSize: 28, weight: .bold)
        let version = NSTextField(labelWithString: AppInfo.displayVersion)
        version.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        version.textColor = .secondaryLabelColor
        let channel = NSTextField(labelWithString: AppInfo.releaseChannel == "local" ? "LOCAL BUILD" : AppInfo.releaseChannel.uppercased())
        channel.font = NSFont.monospacedSystemFont(ofSize: 9, weight: .bold)
        channel.textColor = NSColor(hex: "68DDB1")

        let identity = NSStackView(views: [title, version, channel])
        identity.orientation = .vertical
        identity.alignment = .leading
        identity.spacing = 4
        let hero = NSStackView(views: [logo, identity])
        hero.orientation = .horizontal
        hero.alignment = .centerY
        hero.spacing = 18

        let divider = NSBox()
        divider.boxType = .separator

        let description = NSTextField(wrappingLabelWithString: "一个只看 Codex 每周总额度的 macOS 桌面组件。数据通过本机 Codex 读取，不上传账户、用量或背景图片。")
        description.font = NSFont.systemFont(ofSize: 13)
        description.textColor = .labelColor
        description.maximumNumberOfLines = 3

        updateStatus.font = NSFont.systemFont(ofSize: 11)
        updateStatus.textColor = .secondaryLabelColor
        refreshUpdateStatus()

        checkButton.title = "检查更新…"
        checkButton.target = self
        checkButton.action = #selector(checkForUpdates)

        let footer = NSTextField(labelWithString: "配置文件采用可移植的 .quotaglowconfig 格式")
        footer.font = NSFont.systemFont(ofSize: 10.5)
        footer.textColor = .tertiaryLabelColor

        let stack = NSStackView(views: [hero, divider, description, updateStatus, checkButton, footer])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack)

        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 76),
            logo.heightAnchor.constraint(equalToConstant: 76),
            divider.widthAnchor.constraint(equalTo: stack.widthAnchor),
            description.widthAnchor.constraint(equalTo: stack.widthAnchor),
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 34),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -34),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -24)
        ])
    }

    private func refreshUpdateStatus() {
        if AppInfo.sparkleConfigurationReady {
            updateStatus.stringValue = "Sparkle 安全自动更新已就绪"
        } else {
            updateStatus.stringValue = "本地发布通道 · 建立 GitHub Release 后启用更新源"
        }
    }

    @objc private func checkForUpdates() {
        onCheckForUpdates?()
    }
}
