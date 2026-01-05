// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TmuxMenuBar",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "TmuxMenuBar",
            path: "Sources/TmuxMenuBar"
        )
    ]
)
