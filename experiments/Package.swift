// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OrderingExperiments",
    platforms: [
        .macOS(.v14),
    ],
    targets: [
        .target(
            name: "OrderingExperiments",
            path: "Sources/OrderingExperiments"
        ),
        .testTarget(
            name: "OrderingExperimentsTests",
            dependencies: ["OrderingExperiments"],
            path: "Tests/OrderingExperimentsTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
