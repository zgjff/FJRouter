import Testing
import Foundation
@testable import FJRouter

struct FJRouterEventActionTests {
    @Test func emptyPath() {
        #expect(throws: FJRouterEventAction.CreateError.emptyPath) {
            let _ = try FJRouterEventAction(path: "")
        }
    }
    
    @Test func emptyName() {
        #expect(throws: FJRouterEventAction.CreateError.emptyName) {
            let _ = try FJRouterEventAction(path: "/", name: "")
        }
    }
    
    @Test func testEmptyParameters() throws {
        let a1 = try FJRouterEventAction(path: "/settings/detail/abc")
        #expect(a1.pathParameters.isEmpty)
        let a2 = try FJRouterEventAction(path: "/settings/detail/abc?ip=123")
        #expect(a2.pathParameters.isEmpty)
    }
    
    @Test func testParamters() throws  {
        let a1 = try FJRouterEventAction(path: "/user/:id")
        #expect(a1.pathParameters == ["id"])
        let a2 = try FJRouterEventAction(path: "/user/:id/check/:age")
        #expect(a2.pathParameters == ["id", "age"])
        let a3 = try FJRouterEventAction(path: "/user/:id/check/:age/play/:game")
        #expect(a3.pathParameters == ["id", "age", "game"])
        let a4 = try FJRouterEventAction(path: "/user/:id/check/:age/play/:game?query?pid=1&gid=2")
        #expect(a4.pathParameters == ["id", "age", "game"])
    }
    
    @Test func matchRegExpAsPrefixWithoutParameter() {
        let pattern = "/settings/detail"
        let action = try! FJRouterEventAction(path: pattern)
        
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
        let a1 = try FJRouterEventAction(path: "/a")
        let a2 = try FJRouterEventAction(path: "/a")
        #expect(a1 == a2)
    }
    
    @Test func testDifferentAction() throws {
        let a1 = try FJRouterEventAction(path: "/a")
        let a2 = try FJRouterEventAction(path: "a")
        let a3 = try FJRouterEventAction(path: "a/")
        let a4 = try FJRouterEventAction(path: "/a/")
        let actions: Set<FJRouterEventAction> = [a1, a2, a3, a4]
        #expect(actions.count == 4)
    }
}
