// swift-tools-version: 5.9
import PackageDescription

// Note: the image/audio library is NOT bundled through SwiftPM (a resource path outside the target
// directory is rejected). The Xcode project (StillFantasyiPad.xcodeproj) embeds `Resources/` as a folder
// reference; at runtime missing images are fetched from the Cloudflare R2 bucket and cached on disk.
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
            path: "Sources/StillFantasyiPad"
        )
    ]
)
