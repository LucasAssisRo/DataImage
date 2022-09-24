// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DataImage",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "DataImage",
            targets: ["DataImage"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DataImage",
            dependencies: []
        ),
    ]
)
