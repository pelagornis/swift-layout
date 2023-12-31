// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-layout",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .tvOS(.v13)
    ],
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
