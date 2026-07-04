// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "FXConvert",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "FXConvert",
            path: "Sources/FXConvert"
        ),
        // The extra -F/-rpath flags below only matter on machines with just Xcode Command Line
        // Tools installed (no full Xcode.app), where Testing.framework lives outside the default
        // search paths. They're no-ops on CI/full-Xcode machines, where the framework is already
        // found in its standard location.
        .testTarget(
            name: "FXConvertTests",
            dependencies: ["FXConvert"],
            path: "Tests/FXConvertTests",
            swiftSettings: [
                .unsafeFlags(["-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks"])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker", "-rpath", "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker", "-rpath", "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/usr/lib"
                ])
            ]
        )
    ]
)
