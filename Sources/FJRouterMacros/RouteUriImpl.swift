//
//  RouteUriImpl.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/28.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct RouteUri: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let caseDecl = declaration.as(EnumCaseDeclSyntax.self) else {
            throw FJRouterMacroError(text: "@Uri only support enum case")
        }
        context.lexicalContext
        return [
            """
                var uri: any FJRouteTargetURI {
                return 1
            }
            """
        ]
    }
}
