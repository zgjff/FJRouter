import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouterMatchTests {
    @Test func matchWithoutParameter() async throws {
        let route = try! FJRoute(path: "/settings/detail", builder: _builder)
        let (matches1, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "settings/detail")!)
        #expect(matches1.isEmpty)
        
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
        #expect(matches[0].route.uri.path == "/")
        #expect(matches[1].route.uri.path == "a")
        #expect(matches[2].route.uri.path == "b")
        #expect(matches[3].route.uri.path == "c")
        #expect(matches[4].route.uri.path == "/d")
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
        #expect(matches[0].route.uri.path == "/user/:id")
        #expect(matches[1].route.uri.path == "book/:bookId")
        #expect(matches[2].route.uri.path == "detail")
        #expect(matches[3].route.uri.path == "show/:page")
        
        #expect(pathParameters.count == 3)
        #expect(pathParameters["id"] == "123")
        #expect(pathParameters["bookId"] == "456")
        #expect(pathParameters["page"] == "789")
    }
    
    @Test func matchParentMushStartWithSlash1() async throws {
        let route = try! FJRoute(path: "/a", builder: _builder, routes: [
            try! FJRoute(path: "b", builder: _builder, routes: [
                try! FJRoute(path: "c", builder: _builder, routes: [
                    try! FJRoute(path: "d", builder: _builder, routes: [
                    ])
                ])
            ])
        ])
        let (matches1, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b/c/d")!)
        #expect(matches1.count == 4)
        
        let (matches2, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b")!)
        #expect(matches2.count == 2)
        
        let (matches3, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b/d")!)
        #expect(matches3.count == 0)
        
        let (matches4, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/d")!)
        #expect(matches4.count == 0)
    }
    
    @Test func matchParentMushStartWithSlash2() async throws {
        let route = try! FJRoute(path: "a", builder: _builder, routes: [
            try! FJRoute(path: "b", builder: _builder, routes: [
                try! FJRoute(path: "c", builder: _builder, routes: [
                    try! FJRoute(path: "d", builder: _builder, routes: [
                    ])
                ])
            ])
        ])
        let (matches1, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b/c/d")!)
        #expect(matches1.count == 0)
        
        let (matches2, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "a/b/c/d")!)
        #expect(matches2.count == 4)

        let (matches3, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/b/d")!)
        #expect(matches3.count == 0)
        
        let (matches4, _) = FJRouteMatch.match(route: route, byUrl: URL(string: "/a/d")!)
        #expect(matches4.count == 0)
    }
    
    @Test func matchParameterWithURlDecode() {
        let route1 = try! FJRoute(path: "/user/:name", builder: _builder)
        let (matches1, pathParameters1) = FJRouteMatch.match(route: route1, byUrl: URL(string: "/user/%e5%90%8d%e5%ad%97")!)
        #expect(!matches1.isEmpty)
        #expect(pathParameters1["name"] == "名字")
        
        let route2 = try! FJRoute(path: "/web/:url/next", builder: _builder)
        let (matches2, pathParameters2) = FJRouteMatch.match(route: route2, byUrl: URL(string: "/web/https%3a%2f%2fcn.bing.com%2fsearch%3fq%3d%e5%a4%a9%e6%b0%94%26cvid%3ddf4490e4326d4fbeb/next")!)
        #expect(!matches2.isEmpty)
        #expect(pathParameters2["url"] == "https://cn.bing.com/search?q=天气&cvid=df4490e4326d4fbeb")
        
        let route3 = try! FJRoute(path: "/web/:url", builder: _builder)
        let (matches3, pathParameters3) = FJRouteMatch.match(route: route3, byUrl: URL(string: "/web/https%3a%2f%2fcn.bing.com%2fsearch%3fq%3d%e5%a4%a9%e6%b0%94%26cvid%3ddf4490e4326d4fbeb?tab=10")!)
        #expect(!matches3.isEmpty)
        #expect(pathParameters3["url"] == "https://cn.bing.com/search?q=天气&cvid=df4490e4326d4fbeb")
    }
    
    fileprivate var _builder: FJRoute.Builder = { _ in
        return UIViewController()
    }
}
