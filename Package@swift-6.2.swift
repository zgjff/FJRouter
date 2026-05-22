// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FJRouter",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "FJRouter", targets: ["FJRouter"]),
    ],
    targets: [
        .target(name: "FJRouter",
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "RouterTests",
            dependencies: [
                "FJRouter",
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
