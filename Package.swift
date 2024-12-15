// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FluidityKit",
    products: [
        .library(
            name: "FluidityKit",
            targets: ["FluidityKit"]),
    ],
    targets: [
        .target(
            name: "FluidityKit"),
        .testTarget(
            name: "FluidityKitTests",
            dependencies: ["FluidityKit"]
        ),
    ]
)
