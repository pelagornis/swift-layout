// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "swift-layout",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Layout",
            targets: ["Layout"]),
    ],
    targets: [
        .target(
            name: "Layout"),
        .testTarget(
            name: "LayoutTests",
            dependencies: ["Layout"]),
    ]
)
