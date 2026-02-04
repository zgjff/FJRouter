//
//  FJRouteTargetInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

extension FJRouteTarget {
    /// 拦截器行为
    ///
    /// guard: 不可以跳转, 即路由守卫
    ///
    /// pass: 不需要重定向
    ///
    /// new(xxx)需要重定向到新路由路径
    public enum InterceptorAction: @unchecked Sendable {
        /// 守卫拦截: 不可以跳转, 即路由守卫
        case `guard`
        /// 通过: 不需要重定向
        case pass
        /// 需要重定向到新路由路径
        case redirect(_ target: any FJRouteTargetType)
    }
}

/// 路由拦截器协议
public protocol FJRouteTargetInterceptor: Sendable {
    /// 优先级
    var priority: Int { get }
    
    /// 开始处理拦截行为: 注意不要执行太耗时操作
    /// - Parameters:
    ///   - route: 要执行拦截的路由
    ///   - chain: 路由链路
    /// - Returns: 拦截行为
    func onActive(route: any FJRouteTargetType, chain: FJRouteMatchChain) async -> FJRouteTarget.InterceptorAction
}
