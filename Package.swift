// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "FXConvert",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "FXConvert",
            path: "Sources/FXConvert"
        )
    ]
)
