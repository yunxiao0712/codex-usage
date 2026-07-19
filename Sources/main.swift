import AppKit
import Foundation
import ServiceManagement

if let importIndex = CommandLine.arguments.firstIndex(of: "--import-background"),
   CommandLine.arguments.indices.contains(importIndex + 1) {
    do {
        let url = URL(fileURLWithPath: CommandLine.arguments[importIndex + 1])
        let stored = try BackgroundAssetStore.importImage(from: url)
        print(stored.path)
        exit(EXIT_SUCCESS)
    } catch {
        fputs("FAIL \(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if CommandLine.arguments.contains("--clear-background") {
    do {
        try BackgroundAssetStore.clear()
        print("cleared")
        exit(EXIT_SUCCESS)
    } catch {
        fputs("FAIL \(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if let exportIndex = CommandLine.arguments.firstIndex(of: "--export-configuration"),
          CommandLine.arguments.indices.contains(exportIndex + 1) {
    let url = URL(fileURLWithPath: CommandLine.arguments[exportIndex + 1])
    do {
        try ConfigurationStore.export(to: url)
        print(url.path)
        exit(EXIT_SUCCESS)
    } catch {
        fputs("FAIL \(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if let importIndex = CommandLine.arguments.firstIndex(of: "--import-configuration"),
          CommandLine.arguments.indices.contains(importIndex + 1) {
    let url = URL(fileURLWithPath: CommandLine.arguments[importIndex + 1])
    do {
        try ConfigurationStore.importConfiguration(from: url)
        print("imported")
        exit(EXIT_SUCCESS)
    } catch {
        fputs("FAIL \(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if CommandLine.arguments.contains("--login-status") {
    switch SMAppService.mainApp.status {
    case .notRegistered: print("not_registered")
    case .enabled: print("enabled")
    case .requiresApproval: print("requires_approval")
    case .notFound: print("not_found")
    @unknown default: print("unknown")
    }
    exit(EXIT_SUCCESS)
} else if CommandLine.arguments.contains("--self-test") {
    do {
        try SelfTest.run()
        exit(EXIT_SUCCESS)
    } catch {
        fputs("FAIL \(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if let previewIndex = CommandLine.arguments.firstIndex(of: "--export-previews"),
   CommandLine.arguments.indices.contains(previewIndex + 1) {
    _ = NSApplication.shared
    let directory = URL(fileURLWithPath: CommandLine.arguments[previewIndex + 1], isDirectory: true)
    do {
        let urls = try SkinPreviewExporter.export(to: directory)
        urls.forEach { print($0.path) }
        exit(EXIT_SUCCESS)
    } catch {
        fputs("\(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if let iconIndex = CommandLine.arguments.firstIndex(of: "--export-app-icon"),
          CommandLine.arguments.indices.contains(iconIndex + 1) {
    _ = NSApplication.shared
    let url = URL(fileURLWithPath: CommandLine.arguments[iconIndex + 1])
    do {
        try AppIconExporter.exportPNG(to: url)
        print(url.path)
        exit(EXIT_SUCCESS)
    } catch {
        fputs("FAIL \(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else if let currentPreviewIndex = CommandLine.arguments.firstIndex(of: "--export-current-preview"),
          CommandLine.arguments.indices.contains(currentPreviewIndex + 1) {
    _ = NSApplication.shared
    let url = URL(fileURLWithPath: CommandLine.arguments[currentPreviewIndex + 1])
    do {
        try SkinPreviewExporter.exportCurrent(to: url)
        print(url.path)
        exit(EXIT_SUCCESS)
    } catch {
        fputs("\(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
} else {
    MainActor.assumeIsolated {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        application.run()
    }
}
