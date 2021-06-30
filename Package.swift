// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataImage",
    platforms: [
        .macOS(.v11), .iOS(.v14), .watchOS(.v7)
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
