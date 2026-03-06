import Foundation
import Testing
@testable import FJRouter
#if canImport(UIKit)
import UIKit
@Suite("register route test")
struct FJRouteRegisterTest {
    @Test("equtalPath test for caseSensitive = true") func equtalPathCaseSensitive() async {
        var config = FJRouteJumpProviderConfig()
        config.assertRegisterErrorInDebug = false
        let store = FJRouteJumpProviderStore(config: config)
        
        await #expect(throws: Never.self) {
            try await store.addRoute(Route1.app)
        }
        
        await #expect(throws: FJRouteTarget.RegisterError.uriSuffixWithSlash(target: Route1.a1)) {
            try await store.addRoute(Route1.a1)
        }
    }
}

extension FJRouteRegisterTest {
    fileprivate class RouteCheckLoginInterceptor: @unchecked Sendable, FJRouteTargetInterceptor {
        var priority: Int {
            return 0
        }
        
        func onActive(route: any FJRouteTargetType, chain: FJRouteMatchChain) async -> FJRouteTarget.InterceptorAction {
            return .pass
        }
    }
    
    fileprivate enum Route1: FJRouteTargetType {
        case app
        case a1
        
        var uri: any FJRouteTargetURI {
            switch self {
            case .app:
                return FJRouteTarget.CommonURI(path: "/")
            case .a1:
                return FJRouteTarget.CommonURI(path: "/a1/")
            }
        }
        
        var builder: FJRouteTarget.Builder? {
            switch self {
            case .app:
                return nil
            case .a1:
                return FJRouteTarget.Builder { info in
                    return UIViewController()
                }
            }
        }
        
        var animator: FJRouteTarget.Animator {
            FJRouteTarget.Animator { info in
                return FJRouteAnimatorProviders.AppRootController()
            }
        }
        
        var interceptors: [any FJRouteTargetInterceptor] {
            switch self {
            case .app:
                return [RouteCheckLoginInterceptor()]
            case .a1:
                 return []
            }
        }
        
        var parent: (any FJRouteTargetType)? {
            switch self {
            case .app, .a1:
                return nil
            }
        }
    }
}

#endif
