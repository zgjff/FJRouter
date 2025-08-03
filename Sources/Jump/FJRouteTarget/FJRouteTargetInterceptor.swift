//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation

/// 路由拦截器
public protocol FJRouteTargetInterceptor: Sendable {
    /// 重定向
    /// - Parameter state: 路由跳转信息
    /// - Returns: 行为
    func redirectRouteNext(state: FJRouterState) async -> FJRoute.RedirectorNext
    
    func willShow(target: FJRouteTargetType)
}
