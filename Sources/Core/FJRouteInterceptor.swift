//
//  FJRouteInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
/// 路由拦截器协议
public protocol FJRouteInterceptor: Sendable {
    /// 指向需要重定向的路由。返回`nil`则代表不需要重定向
    ///
    /// 可以携带参数.eg, 目标路由是`/family/:fid`, 则需要完整传入`fid`, 即`/family/123`
    func redirectRoute(state: FJRouterState) async -> String?
}

/// 通用路由拦截器
public struct FJRouteCommonInterceptor: @unchecked Sendable, FJRouteInterceptor {
    private let redirect: (_ state: FJRouterState) async -> String?
    
    /// 初始化方法
    /// - Parameters:
    ///   - redirect: 指向需要重定向的路由
    public init(redirect: @escaping (_ state: FJRouterState) async -> String?) {
        self.redirect = redirect
    }
    
    public func redirectRoute(state: FJRouterState) async -> String? {
        await redirect(state)
    }
}
