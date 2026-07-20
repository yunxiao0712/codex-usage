import AppKit
import Foundation

enum BackgroundAssetStore {
    static func currentImage(preferences: AppPreferences = .shared) -> NSImage? {
        guard let path = preferences.backgroundImagePath else { return nil }
        return NSImage(contentsOfFile: path)
    }

    static func importImage(from source: URL, preferences: AppPreferences = .shared) throws -> URL {
        let values = try source.resourceValues(forKeys: [.fileSizeKey])
        guard (values.fileSize ?? 0) <= 20 * 1_024 * 1_024 else {
            throw NSError(domain: "CodexUsageStrip.Background", code: 1, userInfo: [NSLocalizedDescriptionKey: "背景图片不能超过 20 MB"])
        }
        guard let image = NSImage(contentsOf: source), image.isValid else {
            throw NSError(domain: "CodexUsageStrip.Background", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法读取这张图片"])
        }
        let pixelWidth = image.representations.map(\.pixelsWide).max() ?? Int(image.size.width)
        let pixelHeight = image.representations.map(\.pixelsHigh).max() ?? Int(image.size.height)
        guard pixelWidth <= 8_192, pixelHeight <= 8_192 else {
            throw NSError(domain: "CodexUsageStrip.Background", code: 3, userInfo: [NSLocalizedDescriptionKey: "背景图片尺寸不能超过 8192 × 8192"])
        }

        let ext = source.pathExtension.isEmpty ? "png" : source.pathExtension.lowercased()
        let directory = try backgroundsDirectory()
        try removeStoredBackgrounds(in: directory)
        let destination = directory.appendingPathComponent("custom-background.\(ext)")
        let data = try Data(contentsOf: source)
        try data.write(to: destination, options: .atomic)
        preferences.backgroundImagePath = destination.path
        return destination
    }

    static func clear(preferences: AppPreferences = .shared) throws {
        let directory = try backgroundsDirectory()
        try removeStoredBackgrounds(in: directory)
        preferences.backgroundImagePath = nil
    }

    private static func backgroundsDirectory() throws -> URL {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("Codex Usage Strip/Backgrounds", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func removeStoredBackgrounds(in directory: URL) throws {
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        for url in urls where url.lastPathComponent.hasPrefix("custom-background.") {
            try FileManager.default.removeItem(at: url)
        }
    }
}
