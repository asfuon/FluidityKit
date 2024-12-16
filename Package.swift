// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FluidityKit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FluidityKit",
            targets: ["FluidityKit"]),
    ],
    targets: [
        .target(
            name: "FluidityKit",
            resources: [
                .process("Resources")
            ]),
        .executableTarget(
            name: "FluidityExecTest",
            dependencies: ["FluidityKit"]
        ),
        .testTarget(
            name: "FluidityKitTests",
            dependencies: ["FluidityKit"]
        ),
    ]
)
