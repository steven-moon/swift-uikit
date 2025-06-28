// swift-tools-version:5.9
// Package.swift for SwiftUIKit
//
// A cross-platform SwiftUI component library for AI-native and general apps.
// TODO: Add dependencies (if any) in the future.

import PackageDescription

let package = Package(
    name: "SwiftUIKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SwiftUIKit",
            targets: ["SwiftUIKit"]
        )
    ],
    dependencies: [
        .package(path: "../summa-core-swift-package")
    ],
    targets: [
        .target(
            name: "SwiftUIKit",
            dependencies: [
                .product(name: "SummaCoreSwiftPackage", package: "summa-core-swift-package")
            ],
            path: "Sources/SwiftUIKit"
        ),
        .testTarget(
            name: "SwiftUIKitTests",
            dependencies: ["SwiftUIKit"],
            path: "Tests/SwiftUIKitTests"
        )
    ]
) 