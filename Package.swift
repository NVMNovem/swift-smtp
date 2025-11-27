// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSMTP",
    platforms: [
        .iOS(.v15), .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftSMTP",
            targets: ["SwiftSMTP"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-extras", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftSMTP",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOExtras", package: "swift-nio-extras")
            ],
        ),
        .testTarget(
            name: "SwiftSMTPTests",
            dependencies: ["SwiftSMTP"]
        ),
    ]
)
