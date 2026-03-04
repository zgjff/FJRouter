// swift-tools-version: 6.1
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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1"),
    ],
    targets: [
        .target(name: "FJRouter",
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        
        .testTarget(
            name: "RouterTest",
            dependencies: [
                "FJRouter",
            ],
        ),
        
        .macro(
            name: "FJRouterMacroPlugins",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        .target(name: "FJRouterMacro",
            dependencies: ["FJRouterMacroPlugins"]
        ),
        
        .testTarget(
            name: "MacroTest",
            dependencies: [
                "FJRouterMacro",
                "FJRouterMacroPlugins",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
