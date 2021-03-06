// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeypathAutolayout",
    platforms: [ .iOS(.v11) ],
    products: [
        .library(
            name: "KeypathAutolayout",
            targets: ["KeypathAutolayout"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "KeypathAutolayout",
            dependencies: []),
    ]
)
