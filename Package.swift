// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyContactPoint",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MyContactPoint",
            targets: ["MyContactPoint"]
        ),
    ],
    dependencies: [
        // Supabase Swift client
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
        // PostHog analytics
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "MyContactPoint",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "PostHog", package: "posthog-ios"),
            ]
        ),
        .testTarget(
            name: "MyContactPointTests",
            dependencies: ["MyContactPoint"]
        ),
    ]
)




