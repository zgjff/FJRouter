import Testing
import  Foundation
import UIKit
@testable import FJRouter

struct FJRouterStoreMatchTests {
    @Test func testSuccessNoChildNoRedirect() async throws {
        let config = await createConfig()
        let p = "/details"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        #expect(!result.isError)
        #expect(result.fullPath == p)
        #expect(result.url == url)
        #expect(result.extra as? Int == 123)
        #expect(result.lastMatch != nil)
        #expect(result.lastMatch!.matchedLocation == p)
        #expect(result.lastMatch!.route.path == p)
    }
    
    @Test func testErrorNoChildNoRedirect() async throws {
        let config = await createConfig()
        let p = "/detail"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        #expect(result.isError)
        #expect(result.result == .error(.empty))
        #expect(result.fullPath == "")
        #expect(result.url == url)
        #expect(result.extra as? Int == 123)
    }
    
    @Test func testSuccessDoesNotRedirectNoChildHasRedirect() async throws {
        let config = await createConfig(action: { config in
            await config.addRoute(try! FJRoute(path: "/show/:id", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _  in nil })))
        })
        let p = "/show/123"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        #expect(!result.isError)
        #expect(result.url == url)
        #expect(result.fullPath ==  "/show/:id")
        #expect(result.extra as? Int == 123)
        #expect(result.pathParameters == ["id": "123"])
        #expect(result.lastMatch?.matchedLocation == p)
        #expect(result.lastMatch?.route.path == "/show/:id")
    }
    
    @Test func testSuccessRedirectNoChildHasRedirect() async throws {
        let config = await createConfig(action: { config in
            await config.addRoute(try! FJRoute(path: "/show/:id", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _  in "/pages/78" })))
        })
        let p = "/show/123"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        let rp = "/pages/:id"
        let rurl = "/pages/78"
        #expect(!result.isError)
        #expect(result.url == URL(string: rurl)!)
        #expect(result.fullPath ==  rp)
        #expect(result.extra == nil)
        #expect(result.pathParameters == ["id": "78"])
        #expect(result.lastMatch?.matchedLocation == rurl)
        #expect(result.lastMatch?.route.path == rp)
    }
    
    @Test func testSuccessHasChildHasRedirect() async throws {
        let config = await createConfig()
        let p = "/a/b/c/d"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        let rp = "/details"
        #expect(!result.isError)
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == rp)
        #expect(result.extra == nil)
        #expect(result.lastMatch?.matchedLocation == rp)
        #expect(result.lastMatch?.route.path == rp)
    }
    
    @Test func testSuccessHasChildsHasRedirect() async throws {
        let config = await createConfig(action: { config in
            let r = try! FJRoute(path: "/w", builder: _builder, routes: [
                try! FJRoute(path: "x", builder: _builder, routes: [
                    try! FJRoute(path: "y", builder: _builder, routes: [
                        try! FJRoute(path: "z", builder: _builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/a/b/c" }))
                    ])
                ])
            ])
            await config.addRoute(r)
        })
        let url = URL(string: "/w/x/y/z")!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        let rp = "/a/b/c"
        #expect(!result.isError)
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == rp)
        #expect(result.extra == nil)
        #expect(result.lastMatch?.matchedLocation == rp)
        #expect(result.lastMatch?.route.path == "c")
    }
    
    @Test func testErrorHasChildsHasRedirect() async throws {
        let config = await createConfig(action: { config in
            let r = try! FJRoute(path: "/w", builder: _builder, routes: [
                try! FJRoute(path: "x", builder: _builder, routes: [
                    try! FJRoute(path: "y", builder: _builder, routes: [
                        try! FJRoute(path: "z", builder: _builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/a/b/f" }))
                    ])
                ])
            ])
            await config.addRoute(r)
        })
        let result = try await config.match(url: URL(string: "/w/x/y/z")!, extra: 123, ignoreError: false)
        let rp = "/a/b/f"
        #expect(result.isError)
        #expect(result.result == .error(.empty))
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == "")
        #expect(result.extra == nil)
    }
    
    @Test func testSuccessMultipleRedirects() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! FJRoute(path: "/user", builder: self._builder, routes: [
                FJRoute(path: "settings", builder: self._builder, routes: [
                    FJRoute(path: "reset", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! FJRoute(path: "/info", builder: self._builder, routes: [
                FJRoute(path: "display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/login" }))
            ])
            await config.addRoute(r2)
            let r3 = try! FJRoute(path: "/login", builder: self._builder)
            await config.addRoute(r3)
        })
        let result = try await config.match(url: URL(string: "/user/settings/reset")!, extra: 123, ignoreError: false)
        let rp = "/login"
        #expect(!result.isError)
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == rp)
        #expect(result.extra == nil)
        #expect(result.lastMatch?.matchedLocation == rp)
        #expect(result.lastMatch?.route.path == rp)
    }
    
    @Test func testErrorMultipleRedirects() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! FJRoute(path: "/user", builder: self._builder, routes: [
                FJRoute(path: "settings", builder: self._builder, routes: [
                    FJRoute(path: "reset", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! FJRoute(path: "/info", builder: self._builder, routes: [
                FJRoute(path: "display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/logine" }))
            ])
            await config.addRoute(r2)
            let r3 = try! FJRoute(path: "/login", builder: self._builder)
            await config.addRoute(r3)
        })
        let result = try await config.match(url: URL(string: "/user/settings/reset")!, extra: 123, ignoreError: false)
        let rp = "/logine"
        #expect(result.isError)
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == "")
        #expect(result.result == .error(.empty))
    }
    
    @Test func testLoopRedirect() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! FJRoute(path: "/user", builder: self._builder, routes: [
                FJRoute(path: "settings", builder: self._builder, routes: [
                    FJRoute(path: "reset", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! FJRoute(path: "/info", builder: self._builder, routes: [
                FJRoute(path: "display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/user/settings/reset" }))
            ])
            await config.addRoute(r2)
        })
        let result = try await config.match(url: URL(string: "/user/settings/reset")!, extra: 123, ignoreError: false)
        #expect(result.isError)
        #expect(result.result.isLoop)
        #expect(result.url == URL(string: "/user/settings/reset"))
    }
    
    @Test func testLoopRedirects() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! FJRoute(path: "/user", builder: self._builder, routes: [
                FJRoute(path: "settings", builder: self._builder, routes: [
                    FJRoute(path: "reset", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! FJRoute(path: "/info", builder: self._builder, routes: [
                FJRoute(path: "display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/pkuser/details" }))
            ])
            await config.addRoute(r2)
            let r3 = try! FJRoute(path: "/pkuser/details", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/pkuser/display" }))
            await config.addRoute(r3)
            let r4 = try! FJRoute(path: "/pkuser/display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/pkuser/pages/detail" }))
            await config.addRoute(r4)
            let r5 = try! FJRoute(path: "/pkuser", builder: self._builder, routes: [
                FJRoute(path: "pages", builder: self._builder, routes: [
                    FJRoute(path: "detail", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r5)
            await config.setRedirectLimit(50)
        })
        let result = try await config.match(url: URL(string: "/user/settings/reset")!, extra: 123, ignoreError: false)
        #expect(result.isError)
        #expect(result.result.isLoop)
        #expect(result.url == URL(string: "/pkuser/pages/detail"))
    }
    
    @Test func testRedirectLimit() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! FJRoute(path: "/user", builder: self._builder, routes: [
                FJRoute(path: "settings", builder: self._builder, routes: [
                    FJRoute(path: "reset", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! FJRoute(path: "/info", builder: self._builder, routes: [
                FJRoute(path: "display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/pkuser/details" }))
            ])
            await config.addRoute(r2)
            let r3 = try! FJRoute(path: "/pkuser/details", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/pkuser/display" }))
            await config.addRoute(r3)
            let r4 = try! FJRoute(path: "/pkuser/display", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/pkuser/pages/detail" }))
            await config.addRoute(r4)
            let r5 = try! FJRoute(path: "/pkuser", builder: self._builder, routes: [
                FJRoute(path: "pages", builder: self._builder, routes: [
                    FJRoute(path: "detail", builder: self._builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/info/display" }))
                ])
            ])
            await config.addRoute(r5)
            await config.setRedirectLimit(3)
        })
        let result = try await config.match(url: URL(string: "/user/settings/reset")!, extra: 123, ignoreError: false)
        #expect(result.isError)
        #expect(result.result.isLimit)
        #expect(result.url == URL(string: "/pkuser/display"))
    }
    
    fileprivate var _builder: FJRoute.Builder = .default { state in
        return UIViewController()
    }
}

extension FJRouterStoreMatchTests {
    fileprivate func createConfig(action: ((_ config: FJRouterStore) async -> ())? = nil) async -> FJRouterStore {
        let config = FJRouterStore()
        let r1 = try! FJRoute(path: "/", builder: _builder, routes: [
            try! FJRoute(path: "home", builder: _builder)
        ])
        await config.addRoute(r1)
        let r2 = try! FJRoute(path: "/a", builder: _builder, routes: [
            try! FJRoute(path: "b", builder: _builder, routes: [
                try! FJRoute(path: "c", builder: _builder, routes: [
                    try! FJRoute(path: "/d", builder: _builder, interceptor: FJRouteCommonInterceptor(redirect: { _ in "/details" }))
                ])
            ])
        ])
        await config.addRoute(r2)
        let r3 = try! FJRoute(path: "/details", builder: _builder)
        await config.addRoute(r3)
        let r4 = try! FJRoute(path: "/pages/:id", builder: _builder)
        await config.addRoute(r4)
        let r5 = try! FJRoute(path: "/user/:id", builder: _builder)
        await config.addRoute(r5)
        await config.addRoute(try! FJRoute(path: "/pages/:id", builder: self._builder))
        await action?(config)
        return config
    }
}
