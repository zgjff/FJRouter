import Testing
import Foundation
@testable import FJRouter

struct FJRouterEventMatchTests {
    @Test func testSuccessEmptyParamters() throws {
        let a1 = try FJRouterEventAction(path: "/sendSuccess")
        let p1 = "/sendSuccess"
        let u1 = URL(string: p1)!
        let pairs1 = FJRouter.EventMatch.match(action: a1, byUrl: u1)
        #expect(pairs1 != nil)
        #expect(pairs1?.match.matchedLocation == p1)
        #expect(pairs1?.pathParameters.isEmpty == true)
        
        let p2 = "/sendSuccess"
        let u2 = URL(string: p2)!
        let pairs2 = FJRouter.EventMatch.match(action: a1, byUrl: u2)
        #expect(pairs2 != nil)
        #expect(pairs2?.match.matchedLocation == p2)
        #expect(pairs2?.pathParameters.isEmpty == true)
        
        let a2 = try FJRouterEventAction(path: "sendSuccess")
        let p3 = "/sendSuccess"
        let u3 = URL(string: p3)!
        let pairs3 = FJRouter.EventMatch.match(action: a2, byUrl: u3)
        #expect(pairs3 != nil)
        #expect(pairs3?.match.matchedLocation == p3)
        #expect(pairs3?.pathParameters.isEmpty == true)
    }
    
    @Test func testSuccessParamters() throws {
        let a = try FJRouterEventAction(path: "/users/:userId/")
        let p = "/users/123/"
        let u = URL(string: p)!
        let pairs = FJRouter.EventMatch.match(action: a, byUrl: u)
        #expect(pairs != nil)
        #expect(pairs?.match.matchedLocation == "/users/123/")
        #expect(pairs?.pathParameters == ["userId" : "123"])
        
        let p1 = "/users/123"
        let u1 = URL(string: p1)!
        let pairs1 = FJRouter.EventMatch.match(action: a, byUrl: u1)
        #expect(pairs1 != nil)
        #expect(pairs1?.match.matchedLocation == "/users/123/")
        #expect(pairs1?.pathParameters == ["userId" : "123"])
        
        let p2 = "users/123/"
        let u2 = URL(string: p2)!
        let pairs2 = FJRouter.EventMatch.match(action: a, byUrl: u2)
        #expect(pairs2 != nil)
        #expect(pairs2?.match.matchedLocation == "users/123/")
        #expect(pairs2?.pathParameters == ["userId" : "123"])
        
        let p3 = "users/123"
        let u3 = URL(string: p3)!
        let pairs3 = FJRouter.EventMatch.match(action: a, byUrl: u3)
        #expect(pairs3 != nil)
        #expect(pairs3?.match.matchedLocation == "users/123/")
        #expect(pairs3?.pathParameters == ["userId" : "123"])
        
        let p4 = "/users/123/yrr"
        let u4 = URL(string: p4)!
        let pairs4 = FJRouter.EventMatch.match(action: a, byUrl: u4)
        #expect(pairs4 == nil)
    }
}
