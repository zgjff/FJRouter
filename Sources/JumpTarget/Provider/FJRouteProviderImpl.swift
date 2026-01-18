//
//  FJRouteProviderImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

final class FJRouteProviderImpl: FJRouteProvider, @unchecked Sendable {
    static let shared = FJRouteProviderImpl()
    fileprivate let store: FJRouteProviderRouteStore
    init() {
        store = FJRouteProviderRouteStore()
    }
}

extension FJRouteProviderImpl {
    func register(_ route: any FJRouteTargetType) async {
        await store.addRoute(route)
    }
    
    func go(_ route: any FJRouteTargetType) async {
        
    }
    
    func go(_ url: URL) async {
        
    }
}
