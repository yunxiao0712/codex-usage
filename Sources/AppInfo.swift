import Foundation

enum AppInfo {
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    static var displayVersion: String {
        "版本 \(version)（\(build)）"
    }

    static var releaseChannel: String {
        let value = Bundle.main.object(forInfoDictionaryKey: "QuotaGlowReleaseChannel") as? String
        return value?.isEmpty == false ? value! : "local"
    }

    static var sparkleFeedURL: URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
              let url = URL(string: raw),
              url.scheme?.lowercased() == "https" else { return nil }
        return url
    }

    static var sparklePublicKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return value
    }

    static var sparkleConfigurationReady: Bool {
        sparkleFeedURL != nil && sparklePublicKey != nil
    }
}
