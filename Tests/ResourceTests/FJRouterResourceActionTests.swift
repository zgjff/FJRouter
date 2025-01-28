import Testing
import Foundation
@testable import FJRouter

struct FJRouterResourceActionTests {
    @Test func emptyPath() {
        #expect(throws: FJRouterResource.CreateError.emptyPath) {
            let _ = try FJRouterResource(path: "", value: { _ in 1 })
        }
    }
    
    @Test func emptyName() {
        #expect(throws: FJRouterResource.CreateError.emptyName) {
            let _ = try FJRouterResource(path: "/", name: "", value: { _ in 1})
        }
    }
    
    @Test func testEmptyParameters() throws {
        let a1 = try FJRouterResource(path: "/settings/detail/abc", value: { _ in 1})
        #expect(a1.pathParameters.isEmpty)
        let a2 = try FJRouterResource(path: "/settings/detail/abc?ip=123", value: { _ in 1})
        #expect(a2.pathParameters.isEmpty)
    }
    
    @Test func testParamters() throws  {
        let a1 = try FJRouterResource(path: "/user/:id", value: { _ in 1})
        #expect(a1.pathParameters == ["id"])
        let a2 = try FJRouterResource(path: "/user/:id/check/:age", value: { _ in 1})
        #expect(a2.pathParameters == ["id", "age"])
        let a3 = try FJRouterResource(path: "/user/:id/check/:age/play/:game", value: { _ in 1})
        #expect(a3.pathParameters == ["id", "age", "game"])
        let a4 = try FJRouterResource(path: "/user/:id/check/:age/play/:game?query?pid=1&gid=2", value: { _ in 1})
        #expect(a4.pathParameters == ["id", "age", "game"])
    }
    
    @Test func matchRegExpAsPrefixWithoutParameter() {
        let pattern = "/settings/detail"
        let action = try! FJRouterResource(path: pattern, value: { _ in 1})
        
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
        let a1 = try FJRouterResource(path: "/a", value: { _ in 1})
        let a2 = try FJRouterResource(path: "/a", value: { _ in 1})
        #expect(a1 == a2)
    }
    
    @Test func testDifferentAction() throws {
        let a1 = try FJRouterResource(path: "/a", value: { _ in 1})
        let a2 = try FJRouterResource(path: "a", value: { _ in 1})
        let a3 = try FJRouterResource(path: "a/", value: { _ in 1})
        let a4 = try FJRouterResource(path: "/a/", value: { _ in 1})
        let actions: Set<FJRouterResource> = [a1, a2, a3, a4]
        #expect(actions.count == 4)
    }
}
