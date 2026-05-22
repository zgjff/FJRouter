//
//  FJRouteProviderImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

/// 路由跳转管理实现
final class FJRouteJumpProviderImpl: FJRouteJumpProvider, @unchecked Sendable {
    fileprivate let store: FJRouteJumpProviderStore
    init(config: FJRouteJumpProviderConfig) {
        store = FJRouteJumpProviderStore(config: config)
    }
}

extension FJRouteJumpProviderImpl {
    func register(_ route: any FJRouteTargetType) async throws(FJRouteTarget.RegisterError) {
        try await store.addRoute(route)
    }
    
    func go(_ route: any FJRouteTargetType) async {
        
    }
    
    func go(_ url: URL) async {
        
    }
    
    func tryGo(_ maybeRoute: Any) async {
        if let route = maybeRoute as? FJRouteTargetType {
            return await go(route)
        }
        if let url = maybeRoute as? URL {
            return await go(url)
        }
    }
    
    func viewControllerFor(route: any FJRouteTargetType, ignoreInterceptor: Bool) async throws -> IViewController {
        throw FJRouteMatchError.unRegister(route)
    }
    
    func viewControllerFor(url: URL, ignoreInterceptor: Bool) async throws -> IViewController {
        fatalError()
    }
    
    func viewControllerFor(maybeRoute route: Any, ignoreInterceptor: Bool) async throws -> IViewController {
        fatalError()
    }
}
