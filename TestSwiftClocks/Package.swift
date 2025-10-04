// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestSwiftClocks",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.6"),
    ],
    targets: [
        .executableTarget(
            name: "TestSwiftClocks",
            dependencies: [
                .product(name: "Clocks", package: "swift-clocks")
            ]
        ),
    ]
)
