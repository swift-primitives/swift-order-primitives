// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-order-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Order Primitives",
            targets: ["Order Primitives"]
        ),
        .library(
            name: "Order Primitives Test Support",
            targets: ["Order Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-comparison-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-property-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Order Primitives",
            dependencies: [
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),
        .target(
            name: "Order Primitives Test Support",
            dependencies: [
                "Order Primitives",
                .product(name: "Property Primitives Test Support", package: "swift-property-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Order Primitives Tests",
            dependencies: ["Order Primitives",
                "Order Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
