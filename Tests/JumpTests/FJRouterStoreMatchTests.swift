import Testing
import  Foundation
import UIKit
@testable import FJRouter

struct FJRouterStoreMatchTests {
    @Test func testSuccessNoChildNoRedirect() async throws {
        let config = await createConfig()
        let p = "/details?p=1"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        #expect(!result.isError)
        #expect(result.fullPath == "/details")
        #expect(result.url == url)
        #expect(result.extra() as? Int == 123)
        #expect(result.lastMatch != nil)
        #expect(result.lastMatch!.matchedLocation == "/details")
        #expect(result.lastMatch!.route.uri.path == "/details")
        #expect(result.queryParams == ["p": "1"])
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
        #expect(result.extra() as? Int == 123)
    }
    
    @Test func testSuccessDoesNotRedirectNoChildHasRedirect() async throws {
        let config = await createConfig(action: { config in
            await config.addRoute(try! FJRoute(path: "/show/:id", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _  in .pass })]))
        })
        let p = "/show/123?name=haha&age=18"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        #expect(!result.isError)
        #expect(result.url == url)
        #expect(result.fullPath ==  "/show/:id")
        #expect(result.extra() as? Int == 123)
        #expect(result.pathParameters == ["id": "123"])
        #expect(result.lastMatch?.matchedLocation == "/show/123")
        #expect(result.lastMatch?.route.uri.path == "/show/:id")
        #expect(result.queryParams == ["name": "haha", "age": "18"])
    }
    
    @Test func testSuccessRedirectNoChildHasRedirect() async throws {
        let config = await createConfig(action: { config in
            await config.addRoute(try! FJRoute(path: "/show/:id", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _  in .new("/pages/78") })]))
        })
        let p = "/show/123?name=haha&age=18"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        let rp = "/pages/:id"
        let rurl = "/pages/78"
        #expect(!result.isError)
        #expect(result.url == URL(string: rurl)!)
        #expect(result.fullPath ==  rp)
        #expect(result.extra() == nil)
        #expect(result.pathParameters == ["id": "78"])
        #expect(result.lastMatch?.matchedLocation == rurl)
        #expect(result.lastMatch?.route.uri.path == rp)
        #expect(result.queryParams.isEmpty)
    }
    
    @Test func testSuccessHasChildHasRedirect() async throws {
        let config = await createConfig()
        let p = "/a/b/c/d?name=haha&age=18"
        let url = URL(string: p)!
        let result = try await config.match(url: url, extra: 123, ignoreError: false)
        let rp = "/details"
        #expect(!result.isError)
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == rp)
        #expect(result.extra() == nil)
        #expect(result.lastMatch?.matchedLocation == rp)
        #expect(result.lastMatch?.route.uri.path == rp)
        #expect(result.queryParams.isEmpty)
    }
    
    @Test func testSuccessHasChildsHasRedirect() async throws {
        let config = await createConfig(action: { config in
            let r = try! await FJRoute(path: "/w", builder: _builder, routes: await [
                FJRoute(path: "x", builder: _builder, routes: await [
                    FJRoute(path: "y", builder: _builder, routes: await [
                        FJRoute(path: "z", builder: _builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/a/b/c") })])
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
        #expect(result.extra() == nil)
        #expect(result.lastMatch?.matchedLocation == rp)
        #expect(result.lastMatch?.route.uri.path == "c")
    }
    
    @Test func testErrorHasChildsHasRedirect() async throws {
        let config = await createConfig(action: { config in
            let r = try! await FJRoute(path: "/w", builder: _builder, routes: await [
                FJRoute(path: "x", builder: _builder, routes: await [
                    FJRoute(path: "y", builder: _builder, routes: await [
                        FJRoute(path: "z", builder: _builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/a/b/f") })])
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
        #expect(result.extra() == nil)
    }
    
    @Test func testSuccessMultipleRedirects() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! await FJRoute(path: "/user", builder: self._builder, routes: await [
                FJRoute(path: "settings", builder: self._builder, routes: await [
                    FJRoute(path: "reset", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! await FJRoute(path: "/info", builder: self._builder, routes: await [
                FJRoute(path: "display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/login") })])
            ])
            await config.addRoute(r2)
            let r3 = try! await FJRoute(path: "/login", builder: self._builder)
            await config.addRoute(r3)
        })
        let result = try await config.match(url: URL(string: "/user/settings/reset")!, extra: 123, ignoreError: false)
        let rp = "/login"
        #expect(!result.isError)
        #expect(result.url == URL(string: rp)!)
        #expect(result.fullPath == rp)
        #expect(result.extra() == nil)
        #expect(result.lastMatch?.matchedLocation == rp)
        #expect(result.lastMatch?.route.uri.path == rp)
    }
    
    @Test func testErrorMultipleRedirects() async throws {
        let config = await createConfig(action: { config in
            let r1 = try! await FJRoute(path: "/user", builder: self._builder, routes: await [
                FJRoute(path: "settings", builder: self._builder, routes: await [
                    FJRoute(path: "reset", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! await FJRoute(path: "/info", builder: self._builder, routes: await [
                FJRoute(path: "display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/logine") })])
            ])
            await config.addRoute(r2)
            let r3 = try! await FJRoute(path: "/login", builder: self._builder)
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
            let r1 = try! await FJRoute(path: "/user", builder: self._builder, routes: await [
                FJRoute(path: "settings", builder: self._builder, routes: await [
                    FJRoute(path: "reset", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! await FJRoute(path: "/info", builder: self._builder, routes: await [
                FJRoute(path: "display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/user/settings/reset") })])
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
            let r1 = try! await FJRoute(path: "/user", builder: self._builder, routes: await [
                FJRoute(path: "settings", builder: self._builder, routes: await [
                    FJRoute(path: "reset", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! await FJRoute(path: "/info", builder: self._builder, routes: await [
                FJRoute(path: "display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/pkuser/details") })])
            ])
            await config.addRoute(r2)
            let r3 = try! await FJRoute(path: "/pkuser/details", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/pkuser/display") })])
            await config.addRoute(r3)
            let r4 = try! await FJRoute(path: "/pkuser/display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/pkuser/pages/detail") })])
            await config.addRoute(r4)
            let r5 = try! await FJRoute(path: "/pkuser", builder: self._builder, routes: await [
                FJRoute(path: "pages", builder: self._builder, routes: await [
                    FJRoute(path: "detail", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
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
            let r1 = try! await FJRoute(path: "/user", builder: self._builder, routes: await [
                FJRoute(path: "settings", builder: self._builder, routes: await [
                    FJRoute(path: "reset", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
                ])
            ])
            await config.addRoute(r1)
            let r2 = try! await FJRoute(path: "/info", builder: self._builder, routes: await [
                FJRoute(path: "display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/pkuser/details") })])
            ])
            await config.addRoute(r2)
            let r3 = try! await FJRoute(path: "/pkuser/details", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/pkuser/display") })])
            await config.addRoute(r3)
            let r4 = try! await FJRoute(path: "/pkuser/display", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/pkuser/pages/detail") })])
            await config.addRoute(r4)
            let r5 = try! await FJRoute(path: "/pkuser", builder: self._builder, routes: await [
                FJRoute(path: "pages", builder: self._builder, routes: await [
                    FJRoute(path: "detail", builder: self._builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/info/display") })])
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
    
    fileprivate var _builder: FJRoute.Builder = { _ in
        return UIViewController()
    }
}

extension FJRouterStoreMatchTests {
    fileprivate func createConfig(action: ((_ config: FJRouter.JumpStore) async -> ())? = nil) async -> FJRouter.JumpStore {
        let config = FJRouter.JumpStore()
        let r1 = try! await FJRoute(path: "/", builder: _builder, routes: await [
            try! FJRoute(path: "home", builder: _builder)
        ])
        await config.addRoute(r1)
        let r2 = try! await FJRoute(path: "/a", builder: _builder, routes: await [
            FJRoute(path: "b", builder: _builder, routes: await [
                FJRoute(path: "c", builder: _builder, routes: await [
                    FJRoute(path: "/d", builder: _builder, redirect: [FJRouteCommonRedirector(redirect: { _ in .new("/details") })])
                ])
            ])
        ])
        await config.addRoute(r2)
        let r3 = try! await FJRoute(path: "/details", builder: _builder)
        await config.addRoute(r3)
        let r4 = try! await FJRoute(path: "/pages/:id", builder: _builder)
        await config.addRoute(r4)
        let r5 = try! await FJRoute(path: "/user/:id", builder: _builder)
        await config.addRoute(r5)
        await config.addRoute(try! FJRoute(path: "/pages/:id", builder: self._builder))
        await action?(config)
        return config
    }
}
