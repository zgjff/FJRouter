import Testing
import Foundation
@testable import FJRouter

struct FJRouterEventActionTests {
    @Test func emptyPath() {
        #expect(throws: FJRouter.RegisterURIError.emptyPath) {
            let _ = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: ""))
        }
    }
    
    @Test func emptyName() {
        #expect(throws: FJRouter.RegisterURIError.emptyName) {
            let _ = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/", name: ""))
        }
    }
    
    @Test func testEmptyParameters() throws {
        let a1 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/settings/detail/abc"))
        #expect(a1.pathParameters.isEmpty)
        let a2 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/settings/detail/abc?ip=123"))
        #expect(a2.pathParameters.isEmpty)
    }
    
    @Test func testParamters() throws  {
        let a1 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/user/:id"))
        #expect(a1.pathParameters == ["id"])
        let a2 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/user/:id/check/:age"))
        #expect(a2.pathParameters == ["id", "age"])
        let a3 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/user/:id/check/:age/play/:game"))
        #expect(a3.pathParameters == ["id", "age", "game"])
        let a4 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/user/:id/check/:age/play/:game?query?pid=1&gid=2"))
        #expect(a4.pathParameters == ["id", "age", "game"])
    }
    
    @Test func matchRegExpAsPrefixWithoutParameter() {
        let pattern = "/settings/detail"
        let action = try! FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: pattern))
        
        #expect(action.matchRegExpHasPrefix("/settings/detail") != nil)
        #expect(action.matchRegExpHasPrefix("/settings/detail/abc") != nil)
        #expect(action.matchRegExpHasPrefix("settings/detail") != nil)
        #expect(action.matchRegExpHasPrefix("settings/detail/abc") != nil)
        #expect(action.matchRegExpHasPrefix("/settings/detail/") != nil)
        #expect(action.matchRegExpHasPrefix("settings/detail") != nil)
        #expect(action.matchRegExpHasPrefix("settings/detail/") != nil)
        #expect(action.matchRegExpHasPrefix("/settings/detail/") != nil)
        
        #expect(action.matchRegExpHasPrefix("/") == nil)
        #expect(action.matchRegExpHasPrefix("settings") == nil)
        #expect(action.matchRegExpHasPrefix("/settings") == nil)
        #expect(action.matchRegExpHasPrefix("/settings/Detail") == nil)
        #expect(action.matchRegExpHasPrefix("/settings/details") == nil)
        #expect(action.matchRegExpHasPrefix("settings/Detail") == nil)
        #expect(action.matchRegExpHasPrefix("settings/details") == nil)
    }
    
    @Test func testSameAction() throws {
        let a1 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a"))
        let a2 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a"))
        #expect(a1 == a2)
    }
    
    @Test func testDifferentAction() throws {
        let a1 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a"))
        let a2 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "a"))
        let a3 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "a/"))
        let a4 = try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a/"))
        let actions: Set<FJRouterEventAction> = [a1, a2, a3, a4]
        #expect(actions.count == 4)
    }
}
