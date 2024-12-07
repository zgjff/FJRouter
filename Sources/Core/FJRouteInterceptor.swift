//
//  FJRouteInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
/// 路由拦截器协议
public protocol FJRouteInterceptor: Sendable {
    /// 指向需要重定向的路由。
    func redirectRoute(state: FJRouterState) async throws -> FJRoute.InterceptorDestination
}

extension FJRoute {
    /// 路由拦截器拦截指向
    public enum InterceptorDestination: Sendable, Equatable {
        /// 不需要重定向
        case none
        /// 目标路由路径, 支持携带参数
        ///
        ///     eg:目标路由是`/family/:fid`, 则需要完整传入`fid`, 即`/family/123`
        ///
        ///  如果路由的参数比较多, 或者怕拼写错误, 建议调用`FJRouterState`的`convertLocationBy`方法进行转换
        ///
        ///     eg: let loc = try await state.convertLocationBy(name: "settings", params: ["id": "123", "name": "haha"], queryParams: ["index": "2"])
        case routeLoc(_ loc: String)
        
        public var redirectLocation: String? {
            switch self {
            case .none:
                return nil
            case let .routeLoc(rp):
                return rp.isEmpty ? nil : rp
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case let (.routeLoc(lrp), .routeLoc(rrp)):
                return lrp == rrp
            case (.none, .routeLoc), (.routeLoc, .none):
                return false
            }
        }
    }
}

/// 通用路由拦截器
public struct FJRouteCommonInterceptor: @unchecked Sendable, FJRouteInterceptor {
    private let redirect: (_ state: FJRouterState) async throws -> FJRoute.InterceptorDestination
    
    /// 初始化方法
    /// - Parameters:
    ///   - redirect: 指向需要重定向的路由
    public init(redirect: @escaping (_ state: FJRouterState) async throws -> FJRoute.InterceptorDestination) {
        self.redirect = redirect
    }
    
    public func redirectRoute(state: FJRouterState) async throws -> FJRoute.InterceptorDestination {
        do {
            let dest = try await redirect(state)
            return dest
        } catch {
            return .none
        }
    }
}
