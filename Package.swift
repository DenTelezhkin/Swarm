// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Swarm",
    products: [
        .library(
            name: "Swarm",
            targets: ["Swarm"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Swarm",
            dependencies: []),
        .testTarget(
            name: "SwarmTests",
            dependencies: ["Swarm"]),
    ]
)
