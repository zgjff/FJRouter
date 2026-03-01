import XCTest
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
    "FJRoute": FJRouteMacroImpl.self
]
#endif

final class RouteUriTest: XCTestCase {
    func testUri() throws {
        #if canImport(FJRouterMacros)
        assertMacroExpansion(
                """
                @FJRoute
                public enum Animal {
                    case home
                }
                extension Animal {
                    var name: String {
                        return "aa"
                    }
                }
                """,
                expandedSource: """
                """,
                macros: testMacros
            )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testUri2() throws {
        #if canImport(FJRouterMacros)
        assertMacroExpansion(
                """
                public enum AAA {}
                extension AAA {
                    @FJRoute
                    public enum Animal: Equatable {
                        case home
                    }
                }
                """,
                expandedSource: """
                """,
                macros: testMacros
            )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

@FJRoute
enum AAAA {
case home
}

extension AAAA {
    var a: String {
        return "aaa"
    }
}
