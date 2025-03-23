//
//  FJRouteRedirector.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

#if canImport(UIKit)
import Foundation

extension FJRoute {
    /// 重定向行为
    ///
    /// interception: 不可以跳转, 即路由守卫
    ///
    /// pass: 不需要重定向
    ///
    /// new(xxx)需要重定向到新路由路径: 如果返回的是`nil`, 也不需要重定向
    public enum RedirectorNext: @unchecked Sendable {
        /// 守卫拦截: 不可以跳转, 即路由守卫
        case `guard`
        /// 通过: 不需要重定向
        case pass
        /// 需要重定向到新路由路径: 如果返回的是`nil`, 也不需要重定向
        ///
        /// loc为nil主要是适配`convert`. eg
        ///
        ///     return .new(try? await FJRouter.jump().convertLocation(by: .name("login")))
        case new(_ loc: String?)
    }
}

/// 路由重定向
public protocol FJRouteRedirector: Sendable {
    /// 重定向
    /// - Parameter state: 路由跳转信息
    /// - Returns: 行为
    func redirectRouteNext(state: FJRouterState) async -> FJRoute.RedirectorNext
}

/// 通用路由重定向+守卫
public struct FJRouteCommonRedirector: Sendable, FJRouteRedirector {
    private let redirect: @Sendable (_ state: FJRouterState) async throws -> FJRoute.RedirectorNext
    
    /// 初始化方法
    ///
    ///     let loginRoute = try! FJRoute(path: "/login", name: "login", builder: { info in
    ///         return UIViewController()
    ///     }, redirect: FJRouteCommonRedirector(redirect: { state in
    ///         let hasLogin = xxx
    ///         if hasLogin { // true, 即代表已经登录, 此时允许可以跳转至login路由
    ///             return .original
    ///          }
    ///          // hasLogin: false, 即代表未登录, 此时页面在未登录相关的页面, 如登录/注册/发送验证码...等页面, 此时不允许跳转至login路由, 防止多重的跳转至登录
    ///         return .interception
    ///     }))
    ///
    /// - Parameter redirect: 重定向行为
    public init(redirect: @Sendable @escaping (_ state: FJRouterState) async throws -> FJRoute.RedirectorNext) {
        self.redirect = redirect
    }
    
    public func redirectRouteNext(state: FJRouterState) async -> FJRoute.RedirectorNext {
        do {
            let action = try await redirect(state)
            switch action {
            case .guard, .pass:
                return action
            case .new(let loc):
                guard let floc = loc?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    return .pass
                }
                if floc.isEmpty {
                    return .pass
                }
                return .new(floc)
            }
        } catch {
            return .pass
        }
    }
}
#endif
