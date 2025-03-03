// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FJRouter",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "FJRouter", targets: ["FJRouter"]),
    ],
    targets: [
        .target(name: "FJRouter",
                path: "Sources",
                resources: [.process("PrivacyInfo.xcprivacy")]
               ),
        .testTarget(name: "FJRouterTests",
            dependencies: ["FJRouter"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
