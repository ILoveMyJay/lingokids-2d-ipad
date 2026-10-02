// swift-tools-version: 5.9
import PackageDescription

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
                .process("../../Resources")
            ]
        )
    ]
)
