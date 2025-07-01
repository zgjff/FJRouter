import Testing
import Foundation
@testable import FJRouter

struct FJRouterEventMatchTests {
    @Test func testEmptyParamters() async throws {
        let a1 = try await FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/sendSuccess"))
        let p1 = "/sendSuccess"
        let u1 = URL(string: p1)!
        let pairs1 = FJRouter.EventMatch.match(action: a1, byUrl: u1)
        #expect(pairs1 != nil)
        #expect(pairs1?.match.matchedLocation == p1)
        #expect(pairs1?.pathParameters.isEmpty == true)
        
        let p2 = "sendSuccess"
        let u2 = URL(string: p2)!
        let pairs2 = FJRouter.EventMatch.match(action: a1, byUrl: u2)
        #expect(pairs2 == nil)
        
        let a2 = try await FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "sendSuccess"))
        let p3 = "/sendSuccess"
        let u3 = URL(string: p3)!
        let pairs3 = FJRouter.EventMatch.match(action: a2, byUrl: u3)
        #expect(pairs3 == nil)
        
        let p4 = "sendSuccess"
        let u4 = URL(string: p4)!
        let pairs4 = FJRouter.EventMatch.match(action: a2, byUrl: u4)
        #expect(pairs4 != nil)
    }
    
    @Test func testParamters() async throws {
        let a = try await FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/users/:userId/"))
        let p = "/users/123/"
        let u = URL(string: p)!
        let pairs = FJRouter.EventMatch.match(action: a, byUrl: u)
        #expect(pairs != nil)
        #expect(pairs?.match.matchedLocation == "/users/123/")
        #expect(pairs?.pathParameters == ["userId" : "123"])
        
        let p1 = "/users/123"
        let u1 = URL(string: p1)!
        let pairs1 = FJRouter.EventMatch.match(action: a, byUrl: u1)
        #expect(pairs1 == nil)
        
        let p2 = "users/123/"
        let u2 = URL(string: p2)!
        let pairs2 = FJRouter.EventMatch.match(action: a, byUrl: u2)
        #expect(pairs2 == nil)
        
        let p3 = "users/123"
        let u3 = URL(string: p3)!
        let pairs3 = FJRouter.EventMatch.match(action: a, byUrl: u3)
        #expect(pairs3 == nil)
        
        let p4 = "/users/123/yrr"
        let u4 = URL(string: p4)!
        let pairs4 = FJRouter.EventMatch.match(action: a, byUrl: u4)
        #expect(pairs4 == nil)
        
        let p5 = "/users/123?q=t"
        let u5 = URL(string: p5)!
        let pairs5 = FJRouter.EventMatch.match(action: a, byUrl: u5)
        #expect(pairs5 == nil)
    }
    
    @Test func testNoLastSlashParamters() async throws {
        let a = try await FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/users/:userId"))
        
        let p = "/users/123/"
        let u = URL(string: p)!
        let pairs = FJRouter.EventMatch.match(action: a, byUrl: u)
        #expect(pairs == nil)
        
        let p1 = "/users/123"
        let u1 = URL(string: p1)!
        let pairs1 = FJRouter.EventMatch.match(action: a, byUrl: u1)
        #expect(pairs1 != nil)
        #expect(pairs1?.match.matchedLocation == "/users/123")
        #expect(pairs1?.pathParameters == ["userId" : "123"])

        let p2 = "users/123/"
        let u2 = URL(string: p2)!
        let pairs2 = FJRouter.EventMatch.match(action: a, byUrl: u2)
        #expect(pairs2 == nil)
        
        let p3 = "users/123"
        let u3 = URL(string: p3)!
        let pairs3 = FJRouter.EventMatch.match(action: a, byUrl: u3)
        #expect(pairs3 == nil)
        
        let p4 = "/users/123/yrr"
        let u4 = URL(string: p4)!
        let pairs4 = FJRouter.EventMatch.match(action: a, byUrl: u4)
        #expect(pairs4 == nil)
        
        let p5 = "/users/123?q=t"
        let u5 = URL(string: p5)!
        let pairs5 = FJRouter.EventMatch.match(action: a, byUrl: u5)
        #expect(pairs5 != nil)
        #expect(pairs5?.match.matchedLocation == "/users/123")
        #expect(pairs5?.pathParameters == ["userId" : "123"])
    }
    
    @Test func testMultipleParamters() async throws {
        let a = try await FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/users/:userId/play/games/:pid"))
        
        let p1 = "/users/123/play/games/7648"
        let u1 = URL(string: p1)!
        let pairs1 = FJRouter.EventMatch.match(action: a, byUrl: u1)
        #expect(pairs1 != nil)
        #expect(pairs1?.pathParameters == ["userId": "123", "pid": "7648"])
        
        let p2 = "/users/123/play/games/7648/"
        let u2 = URL(string: p2)!
        let pairs2 = FJRouter.EventMatch.match(action: a, byUrl: u2)
        #expect(pairs2 == nil)
    }
}
