import Testing
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import FJRouter
#if canImport(FJRouterMacros)
@testable import FJRouterMacros
let testMacros: [String: Macro.Type] = [
    "Uri": RouteUri.self,
]
#endif
@Suite("Route Uri Macro tests")
final class RouteUriTest {
    @Test func uriTest() throws {
        #if canImport(FJRouterMacros)
        assertMacroExpansion(
                """
                enum Animal {
                    @Uri("home")
                    case home
                }
                """,
                expandedSource: """
                """,
                macros: testMacros
            )
        #else
        fatalError("Adsfasdf")
        #endif
    }
}
