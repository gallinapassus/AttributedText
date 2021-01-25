// swift-tools-version:5.2
// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AttributedText",
    products: [
        .library(
            name: "AttributedText",
            targets: ["AttributedText"]),
    ],
    targets: [
        .target(
            name: "AttributedText",
            dependencies: []),
        .testTarget(
            name: "AttributedTextTests",
            dependencies: ["AttributedText"]),
    ]
)
