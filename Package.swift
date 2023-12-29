// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-layout",
    products: [
        .library(
            name: "SwiftLayout",
            targets: ["SwiftLayout"]),
    ],
    targets: [
        .target(
            name: "SwiftLayout"),
        .testTarget(
            name: "SwiftLayoutTests",
            dependencies: ["SwiftLayout"]),
    ]
)
