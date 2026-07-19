// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "QuotaGlow",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "QuotaGlow", targets: ["QuotaGlow"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.9.2")
    ],
    targets: [
        .executableTarget(
            name: "QuotaGlow",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("UserNotifications"),
                .unsafeFlags([
                    "-Xlinker", "-rpath",
                    "-Xlinker", "@executable_path/../Frameworks"
                ])
            ]
        )
    ]
)
