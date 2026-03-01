//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2026/3/1.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CaseDetectionImpl: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}
