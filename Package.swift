// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomerFoundation",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "HomerFoundation",
            targets: ["HomerFoundation"]
        )
    ],
    targets: [
        .target(
            name: "HomerFoundation",
            path: "Sources/HomerFoundation"
        ),
        .testTarget(
            name: "HomerFoundationTests",
            dependencies: ["HomerFoundation"],
            path: "Tests/HomerFoundationTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
