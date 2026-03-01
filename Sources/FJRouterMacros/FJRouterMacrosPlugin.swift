//
//  FJRouterMacrosPlugin.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/28.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FJRouterMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RouteUri.self,
        CaseDetectionImpl.self
    ]
}
