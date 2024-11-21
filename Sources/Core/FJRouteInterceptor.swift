//
//  FJRouteInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
/// 路由拦截器协议
public protocol FJRouteInterceptor: Sendable {
    /// 是否需要重定向
    func needRedirect(state: FJRouterState) async -> Bool
    
    /// 指向需要重定向的路由。
    ///
    /// 可以携带参数.eg, 目标路由是`/family/:fid`, 则需要完整传入`fid`, 即`/family/123`
    func redirectRoute(state: FJRouterState) async -> String
}

/// 通用路由拦截器
public struct FJRouteCommonInterceptor: @unchecked Sendable, FJRouteInterceptor {
    private let condition: (_ state: FJRouterState) async -> Bool
    private let redirect: (_ state: FJRouterState) async -> String
    
    /// 初始化方法
    /// - Parameters:
    ///   - condition: 需要重定向的条件
    ///   - redirect: 指向需要重定向的路由
    public init(condition: @escaping (_ state: FJRouterState) async -> Bool, redirect: @escaping (_ state: FJRouterState) async -> String) {
        self.condition = condition
        self.redirect = redirect
    }
    
    public func needRedirect(state: FJRouterState) async -> Bool {
        await condition(state)
    }
    
    public func redirectRoute(state: FJRouterState) async -> String {
        await redirect(state)
    }
}
