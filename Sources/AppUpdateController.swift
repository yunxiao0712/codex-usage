import AppKit
import Foundation

#if canImport(Sparkle)
import Sparkle

@MainActor
final class AppUpdateController {
    private var updaterController: SPUStandardUpdaterController?

    var isReady: Bool { updaterController != nil }

    init() {
        guard AppInfo.sparkleConfigurationReady else { return }
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    func setAutomaticallyChecksForUpdates(_ enabled: Bool) {
        updaterController?.updater.automaticallyChecksForUpdates = enabled
    }
}
#else
@MainActor
final class AppUpdateController {
    var isReady: Bool { false }
    func checkForUpdates() {}
    func setAutomaticallyChecksForUpdates(_ enabled: Bool) {}
}
#endif
