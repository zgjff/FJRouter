import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouteStoreRedirectorTests {
    fileprivate let store: FJRouter.JumpStore
    fileprivate var loginResult = true
    init() async throws {
        store = FJRouter.JumpStore()
        try await addRoutes()
    }
}

private extension FJRouteStoreRedirectorTests {
    func addRoutes() async throws {
        let r1 = try FJRoute(path: "/", name: "root", builder: nil, redirect: FJRouteCommonRedirector(redirect: { state in
            let login = await self.hasLogin()
            if login {
                return .new("/app")
            }
            return .new("/login")
        }))
        await store.addRoute(r1)
        
        let r2 = try FJRoute(path: "/login", name: "login", builder: builderController, redirect: FJRouteCommonRedirector(redirect: { state in
            let login = await self.hasLogin()
            if login { // 已经登录, 可以退出到登录页
                return .pass
            }
            // 否则, 本身就在登录相关页, 没必要再次进入登录页
            return .guard
        }), routes: [
            FJRoute(path: "register", name: "registerAccount", builder: self.builderController)
        ])
        await store.addRoute(r2)
        
        let r3 = try FJRoute(path: "/user/:id", name: "userpage", builder: builderController)
        await store.addRoute(r3)
        
        let r4 = try FJRoute(path: "/settings", name: "settings", builder: builderController, routes: [
            FJRoute(path: "config", name: "settingConfig", builder: self.builderController),
        ])
        await store.addRoute(r4)
        
        let r5 = try FJRoute(path: "/books", name: "books", builder: builderController, redirect: FJRouteCommonRedirector(redirect: { state in
            return .pass
        }), routes: [
            FJRoute(path: "detail/:id", name: "detailBook", builder: self.builderController),
            FJRoute(path: "shop", name: "bookShop", builder: self.builderController, redirect: FJRouteCommonRedirector(redirect: { state in
                return .new("/settings")
            }), routes: [
                FJRoute(path: "center", name: "bookShopCenter", builder: self.builderController)
            ])
        ])
        await store.addRoute(r5)
        
        let r6 = try FJRoute(path: "/games", name: "games", builder: builderController, redirect: FJRouteCommonRedirector(redirect: { state in
            return .guard
        }), routes: [
            FJRoute(path: "detail/:id", name: "detailGame", builder: self.builderController),
        ])
        await store.addRoute(r6)
    }
    
    @MainActor func builderController(_ info: FJRoute.BuilderInfo) -> UIViewController {
        return UIViewController()
    }
    
    func hasLogin() async -> Bool {
        await withCheckedContinuation { continuation in
            continuation.resume(with: .success(true))
        }
    }
}
