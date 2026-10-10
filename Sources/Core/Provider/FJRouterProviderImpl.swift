//
//  FJRouteProviderImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

/// 路由跳转管理实现
final class FJRouterProviderImpl: FJRouterProvider, @unchecked Sendable {
    fileprivate let store: FJRouterProviderStore
    init(config: FJRouterProviderConfig) {
        store = FJRouterProviderStore(config: config)
    }
}

extension FJRouterProviderImpl {
    func register(_ route: any FJRouteTargetType) async throws(FJRouteTarget.RegisterError) {
        try await store.addRoute(route)
    }
    
    func go(_ route: any FJRouteTargetType) async {
        
    }
    
    func go(_ url: URL) async {
        
    }
    
    func viewControllerFor(route: any FJRouteTargetType, ignoreInterceptor: Bool) async throws -> IViewController {
        throw FJRouteMatchError.unRegister(route)
    }
    
    func viewControllerFor(url: URL, ignoreInterceptor: Bool) async throws -> IViewController {
        fatalError()
    }
}
