import Foundation

enum LegacyMigration {
    private static let legacyBundleIdentifier = "app.quotaglow.desktop"
    private static let migrationMarker = "migration.quotaGlow.completed"
    private static let preferenceKeys = [
        "themeID",
        "displayMode",
        "alwaysOnTop",
        "refreshInterval",
        "criticalThreshold",
        "notificationsEnabled",
        "backgroundImagePath",
        "backgroundImageOpacity",
        "overallOpacity",
        "backgroundImageMode",
        "phraseSet",
        "launchAtLoginConfigured",
        "automaticUpdateChecks",
        "windowOrigin",
        "windowSize.strip",
        "windowSize.compact",
        "windowSize.card"
    ]

    static func migrateDefaults(to defaults: UserDefaults) {
        guard !defaults.bool(forKey: migrationMarker) else { return }
        let legacyDomain = defaults.persistentDomain(forName: legacyBundleIdentifier) ?? [:]
        for key in preferenceKeys where defaults.object(forKey: key) == nil {
            if let value = legacyDomain[key] {
                defaults.set(value, forKey: key)
            }
        }
        defaults.set(true, forKey: migrationMarker)
    }

    static func migrateApplicationSupport(preferences: AppPreferences) {
        let fileManager = FileManager.default
        guard let applicationSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }

        let legacyRoot = applicationSupport.appendingPathComponent("QuotaGlow", isDirectory: true)
        let currentRoot = applicationSupport.appendingPathComponent("Codex Usage Strip", isDirectory: true)
        if fileManager.fileExists(atPath: legacyRoot.path),
           !fileManager.fileExists(atPath: currentRoot.path) {
            try? fileManager.copyItem(at: legacyRoot, to: currentRoot)
        }

        guard let legacyPath = preferences.backgroundImagePath,
              legacyPath.hasPrefix(legacyRoot.path) else { return }
        let relativePath = String(legacyPath.dropFirst(legacyRoot.path.count))
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let migratedPath = currentRoot.appendingPathComponent(relativePath).path
        if fileManager.fileExists(atPath: migratedPath) {
            preferences.backgroundImagePath = migratedPath
        }
    }
}
