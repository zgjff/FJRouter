import Testing
import Foundation
import UIKit
@testable import FJRouter

@Suite("无子路由注册测试")
struct FJRegisterRouteNoChildrenTests {
    @Test("无参数路由注册") func registerNoParameters() async throws {
        let route = FJRouter.startJumpProvider { config in
            config.assertRegisterErrorInDebug = false
        }
        await #expect(throws: Never.self) {
            try await route.register(Routes.tab)
        }
    }
}

fileprivate extension FJRegisterRouteNoChildrenTests {
    enum Routes: FJRouteTargetType {
        case app, tab, home
        
        var uri: any FJRouteTargetURI {
            switch self {
            case .app:
                return FJRouteTarget.CommonURI(path: "/")
            case .tab:
                return FJRouteTarget.CommonURI(path: "/tab")
            case .home:
                return FJRouteTarget.CommonURI(path: "/home")
            }
        }
        
        var builder: FJRouteTarget.Builder? {
            switch self {
            case .app:
                return nil
            case .tab, .home:
                return FJRouteTarget.Builder { @MainActor @Sendable info in
                    return UIViewController()
                }
            }
        }
        
        var animator: FJRouteTarget.Animator {
            return FJRouteTarget.Animator { info in
                return FJRouteAnimatorProviders.AppRootController()
            }
        }
        
        var interceptors: [any FJRouteTargetInterceptor] {
            switch self {
            case .app:
                return []
            case .tab:
                return []
            case .home:
                return []
            }
        }
    }
}
