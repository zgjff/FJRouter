//
//  FJRouteMacroImpl.swift
//  FJRouter
//
//  Created by zgjff on 2026/3/1.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct FJRouteMacroImpl: ExtensionMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw FJRouterMacroError(text: "@FJRoute macro now is only for `enum`.")
        }
//        let v = declaration
        
        var isPublic = false
        if let mf = declaration.modifiers.first, mf.tokens(viewMode: .sourceAccurate).contains(where: { $0.tokenKind == .keyword(.public) }) {
            isPublic = true
        }
        
        var routeTargetExists = false
        var hashExists = false
        var equatExists = false
        if let inheritedTypes = enumDecl.inheritanceClause?.inheritedTypes {
            routeTargetExists = inheritedTypes.contains(where: { $0.type.trimmedDescription == "FJRouteTargetType" })
            hashExists = inheritedTypes.contains(where: { $0.type.trimmedDescription == "Hashable" })
            equatExists = inheritedTypes.contains(where: { $0.type.trimmedDescription == "Equatable" })
        }
        
        var decls: [ExtensionDeclSyntax] = []
        
        let preExtensionStr = isPublic ? "public " : " "
        
        if !routeTargetExists {
//            let routeDecl = try ExtensionDeclSyntax(
//                """
//                extension \(type.trimmed): FJRouteTargetType {
//                
//                }
//                """
//            )
//            decls.append(routeDecl)
        }
        
        if !hashExists || !equatExists {
            let heExtensionProtocols: String
            if !hashExists && !equatExists {
                heExtensionProtocols = "Hashable, Equatable"
            } else if !equatExists {
                heExtensionProtocols = "Equatable"
            } else {
                heExtensionProtocols = "Hashable"
            }
            let hashDecl = try ExtensionDeclSyntax(
                """
                extension \(type.trimmed): \(raw: heExtensionProtocols) {
                    \(raw: preExtensionStr)static func == (lhs: Self, rhs: Self) -> Bool {
                        return true
                        //return lhs.uri == rhs.uri
                     }
                    
                    \(raw: preExtensionStr)func hash(into hasher: inout Hasher) {
                            //hasher.combine(uri)
                     }
                }
                """
            )
            decls.append(hashDecl)
        }
        
        return decls
    }
}
//public static func == (lhs: Self, rhs: Self) -> Bool {
//    lhs.id == rhs.id && lhs.path == rhs.path && lhs.caseSensitive == rhs.caseSensitive
//}
//
//public func hash(into hasher: inout Hasher) {
//    hasher.combine(path)
//    hasher.combine(caseSensitive)
//    hasher.combine(id)
//}
