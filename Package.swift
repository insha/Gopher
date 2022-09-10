// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gopher",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "Gopher", targets: ["Gopher"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Gopher", dependencies: []),
        .testTarget(name: "GopherTests", dependencies: ["Gopher"]),
        .testTarget(name: "GopherIntegrationTests", dependencies: ["Gopher"]),
    ]
)
