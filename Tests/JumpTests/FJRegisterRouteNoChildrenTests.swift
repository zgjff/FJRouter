import Testing
import Foundation
@testable import FJRouter

@Suite("无子路由注册测试")
struct FJRegisterRouteNoChildrenTests {
    
}

fileprivate extension FJRegisterRouteNoChildrenTests {
    enum Routes: FJRouteTargetType {
        case app
        case tab
        case home
        
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
            case .tab:
                return nil
            case .home:
                return nil
            }
        }
        
        var animator: FJRouteTarget.Animator {
            switch self {
            case .app:
                return FJRouteTarget.Animator { info in
                    return FJRouteAnimatorProviders.AppRootController()
                }
            case .tab:
                return FJRouteTarget.Animator { info in
                    return FJRouteAnimatorProviders.AppRootController()
                }
            case .home:
                return FJRouteTarget.Animator { info in
                    return FJRouteAnimatorProviders.AutomaticAnimator()
                }
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
