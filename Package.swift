// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "DynamicObject",
    products: [
        .library(name: "DynamicObject", targets: ["DynamicObject"])
    ],
    targets: [
        .target(
            name: "DynamicObject",
            path: "Sources"
        ),
        .testTarget(
            name: "DynamicObjectTests",
            dependencies: ["DynamicObject"],
            path: "Tests"
        )
    ]
)
