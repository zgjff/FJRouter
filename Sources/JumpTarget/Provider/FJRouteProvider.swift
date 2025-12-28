//
//  FJRouteProvider.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

extension FJRouter {
    /// 路由跳转管理中心
    public static func jumpa() -> any FJRouteProvider {
        FJRouteProviderImpl.shared
    }
}

public protocol FJRouteProvider: Sendable {
    func register(_ route: any FJRouteTargetType) async
    
    func go(_ route: any FJRouteTargetType) async
    
    func go(_ url: URL) async
}
