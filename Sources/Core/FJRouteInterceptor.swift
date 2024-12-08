//
//  FJRouteInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
/// 路由拦截器协议
public protocol FJRouteInterceptor: Sendable {
    /// 指向需要重定向的路由路径。返回`nil`, 则代表不需要重定向
    func redirectRoute(state: FJRouterState) async throws -> String?
}

/// 通用路由拦截器
public struct FJRouteCommonInterceptor: @unchecked Sendable, FJRouteInterceptor {
    private let redirect: (_ state: FJRouterState) async throws -> String?
    
    /// 初始化方法
    /// - Parameters:
    ///   - redirect: 指向需要重定向的路由
    public init(redirect: @escaping (_ state: FJRouterState) async throws -> String?) {
        self.redirect = redirect
    }
    
    public func redirectRoute(state: FJRouterState) async throws -> String? {
        do {
            let loc = try await redirect(state)
            if let floc = loc?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return floc.isEmpty ? nil : floc
            }
            return nil
        } catch {
            return nil
        }
    }
}
