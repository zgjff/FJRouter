//
//  FJRouterMacrosPlugin.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/28.
//

#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FJRouterMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RouteUri.self,
        FJRouteMacroImpl.self
    ]
}

#endif
