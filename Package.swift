// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gopher",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "Gopher", targets: ["Gopher"]),
    ],
    dependencies: [
        .package(url: "https://github.com/insha/PreflightPlugin.git", .upToNextMajor(from:"0.1.0")),
    ],
    targets: [
        .target(name: "Gopher",
                dependencies: [],
                plugins: [
                    .plugin(name: "PreflightPlugin", package: "PreflightPlugin"),
                ]
        ),
        .testTarget(name: "GopherTests", dependencies: ["Gopher"]),
        .testTarget(name: "GopherIntegrationTests", dependencies: ["Gopher"]),
    ]
)
