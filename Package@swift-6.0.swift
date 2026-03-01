// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FJRouter",
    platforms: [
        .macOS(.v10_15), // why: support test macros, macros only can test for mac
        .iOS(.v13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "FJRouter", targets: ["FJRouter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.1"),
    ],
    targets: [
        .macro(
            name: "FJRouterMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        .target(name: "FJRouter",
            dependencies: ["FJRouterMacros"],
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        
        .testTarget(
            name: "MacroTest",
            dependencies: [
                "FJRouterMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
