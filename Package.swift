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
        // MARK: - Namespace
        .library(
            name: "Order Primitive",
            targets: ["Order Primitive"]
        ),

        // MARK: - Sub-namespace targets
        .library(
            name: "Order Direction Primitives",
            targets: ["Order Direction Primitives"]
        ),
        .library(
            name: "Order Comparator Primitives",
            targets: ["Order Comparator Primitives"]
        ),
        .library(
            name: "Order Orderable Primitives",
            targets: ["Order Orderable Primitives"]
        ),
        .library(
            name: "Order Projection Primitives",
            targets: ["Order Projection Primitives"]
        ),

        // MARK: - Integration
        .library(
            name: "Order Primitives Standard Library Integration",
            targets: ["Order Primitives Standard Library Integration"]
        ),

        // MARK: - Umbrella
        .library(
            name: "Order Primitives",
            targets: ["Order Primitives"]
        ),

        // MARK: - Test Support
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
        // MARK: - Namespace
        .target(
            name: "Order Primitive",
            dependencies: []
        ),

        // MARK: - Sub-namespace targets (per [MOD-031])
        .target(
            name: "Order Direction Primitives",
            dependencies: [
                "Order Primitive",
            ]
        ),
        .target(
            name: "Order Comparator Primitives",
            dependencies: [
                "Order Primitive",
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
            ]
        ),
        .target(
            name: "Order Orderable Primitives",
            dependencies: [
                "Order Primitive",
                "Order Comparator Primitives",
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),
        .target(
            name: "Order Projection Primitives",
            dependencies: [
                "Order Primitive",
                "Order Direction Primitives",
                "Order Comparator Primitives",
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
            ]
        ),

        // MARK: - Integration
        .target(
            name: "Order Primitives Standard Library Integration",
            dependencies: [
                "Order Comparator Primitives",
                "Order Orderable Primitives",
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Order Primitives",
            dependencies: [
                "Order Primitive",
                "Order Direction Primitives",
                "Order Comparator Primitives",
                "Order Orderable Primitives",
                "Order Projection Primitives",
                "Order Primitives Standard Library Integration",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Order Primitives Test Support",
            dependencies: [
                "Order Primitives",
                .product(name: "Property Primitives Test Support", package: "swift-property-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Order Primitives Tests",
            dependencies: [
                "Order Primitives",
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
