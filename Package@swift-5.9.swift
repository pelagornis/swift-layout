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
            name: "Layout",
            targets: ["Layout"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", "509.0.0"..<"511.0.0"),
    ],
    targets: [
        .target(
            name: "Layout",
            dependencies: [
                "LayoutMacros"
            ]
        ),
        .macro(
            name: "LayoutMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "LayoutTests",
            dependencies: ["Layout"]
        ),
        .testTarget(
            name: "LayoutMacrosTests",
            dependencies: [
                "LayoutMacros",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        )
        
    ]
)
