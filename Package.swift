// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KeySound",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "KeySound",
            targets: ["KeySound"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KeySound",
            path: "Sources/KeySound"
        )
    ]
)
