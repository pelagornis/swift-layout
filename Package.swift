// swift-tools-version: 6.0
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
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.4")
    ],
    targets: [
        .target(
            name: "Layout"),
        .testTarget(
            name: "LayoutTests",
            dependencies: ["Layout"]),
    ]
)
