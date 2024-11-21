import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouterMatchTests {
    @Test func matchWithoutParameter() async throws {
        let route = try! FJRoute(path: "/settings/detail", builder: _builder)
        let (matches1, pathParameters1) = FJRouteMatch.match(route: route, byUrl: URL(string: "/settings/detail")!)
        #expect(matches1.count == 1)
        #expect(matches1[0].route == route)
        #expect(matches1[0].matchedLocation == "/settings/detail")
        #expect(pathParameters1.isEmpty)
        
        let (matches2, pathParameters2) = FJRouteMatch.match(route: route, byUrl: URL(string: "/settings/detail?q=a")!)
        #expect(matches2.count == 1)
        #expect(matches2[0].route == route)
        #expect(matches2[0].matchedLocation == "/settings/detail")
        #expect(pathParameters2.isEmpty)
    }
    
    @Test func matchWithParameter() async throws {
        let route = try! FJRoute(path: "/users/:userId", builder: _builder)
        let (matches1, pathParameters1) = FJRouteMatch.match(route: route, byUrl: URL(string: "/users/123")!)
        #expect(matches1.count == 1)
        #expect(matches1[0].route == route)
        #expect(matches1[0].matchedLocation == "/users/123")
        #expect(pathParameters1["userId"] == "123")
        
        let (matches2, pathParameters2) = FJRouteMatch.match(route: route, byUrl: URL(string: "/users/123?q=a")!)
        #expect(matches2.count == 1)
        #expect(matches2[0].route == route)
        #expect(matches2[0].matchedLocation == "/users/123")
        #expect(pathParameters2["userId"] == "123")
    }
    
    @Test func matchWithChildRouteNoParameter() async throws {
        let route = try! FJRoute(path: "/", builder: _builder, routes: [
            try! FJRoute(path: "a", builder: _builder, routes: [
                try! FJRoute(path: "b", builder: _builder, routes: [
                    try! FJRoute(path: "c", builder: _builder, routes: [
                        try! FJRoute(path: "/d", builder: _builder)
                    ])
                ])
            ])
        ])
        let (matches, pathParameters) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b/c/d")!)
        #expect(pathParameters.isEmpty)
        #expect(matches.count == 5)
        #expect(matches[0].route.path == "/")
        #expect(matches[1].route.path == "a")
        #expect(matches[2].route.path == "b")
        #expect(matches[3].route.path == "c")
        #expect(matches[4].route.path == "/d")
    }
    
    @Test func matchWithChildRouteWithParameter() async throws {
        let route = try! FJRoute(path: "/user/:id", builder: _builder, routes: [
            try! FJRoute(path: "book/:bookId", builder: _builder, routes: [
                try! FJRoute(path: "detail", builder: _builder, routes: [
                    try! FJRoute(path: "show/:page", builder: _builder)
                ])
            ])
        ])
        let (matches, pathParameters) = FJRouteMatch.match(route: route, byUrl: URL(string: "/user/123/book/456/detail/show/789")!)
        #expect(matches.count == 4)
        #expect(matches[0].route.path == "/user/:id")
        #expect(matches[1].route.path == "book/:bookId")
        #expect(matches[2].route.path == "detail")
        #expect(matches[3].route.path == "show/:page")
        
        #expect(pathParameters.count == 3)
        #expect(pathParameters["id"] == "123")
        #expect(pathParameters["bookId"] == "456")
        #expect(pathParameters["page"] == "789")
    }
    
    @Test func matchParentMushStartWithSlash() async throws {
        let route = try! FJRoute(path: "a", builder: _builder, routes: [
            try! FJRoute(path: "b", builder: _builder, routes: [
            ])
        ])
        let (matches1, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b")!)
        #expect(matches1.isEmpty)
        
        let (matches2, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "a/b")!)
        #expect(matches2.isEmpty)
    }
    
    private var _builder: (@MainActor (_ state: FJRouterState) -> UIViewController) = { _ in
        return UIViewController()
    }
}
