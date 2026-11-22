// swift-tools-version: 5.9
import PackageDescription

// Note: the media library (`Resources/images`, `Resources/audio`) is embedded as a folder reference
// in `StillFantasyiPad.xcodeproj` and falls back to Cloudflare R2 at runtime.
// Structured species metadata (`Data/species.json`) is bundled directly in both SwiftPM and Xcode.
let package = Package(
    name: "StillFantasyiPad",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "StillFantasyiPad",
            targets: ["StillFantasyiPad"]
        )
    ],
    targets: [
        .executableTarget(
            name: "StillFantasyiPad",
            path: "Sources/StillFantasyiPad",
            resources: [
                .copy("Data/species.json")
            ]
        ),
        .testTarget(
            name: "StillFantasyiPadTests",
            dependencies: ["StillFantasyiPad"],
            path: "Tests/StillFantasyiPadTests"
        )
    ]
)
