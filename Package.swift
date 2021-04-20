// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pagarme-swift-ios",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "pagarme-swift-ios", targets: ["pagarme-swift-ios", "RSA"]),
        .library(name: "pagarme-swift-ios-static", type: .static, targets: ["pagarme-swift-ios", "RSA"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "RSA",
                path: "Sources/objc",
                publicHeadersPath: "."),
        .target(
            name: "pagarme-swift-ios",
            dependencies: ["RSA"]),
        .testTarget(
            name: "pagarme-swift-iosTests",
            dependencies: ["pagarme-swift-ios", "RSA"]),
    ]
)
