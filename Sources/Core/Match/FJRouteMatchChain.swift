//
//  FJRouteMatchChain.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/19.
//

import Foundation
/// 路由匹配链路
public struct FJRouteMatchChain: Sendable {
    public let originalDestination: PageDestination
    /// 路由重定向
    public let redirects: [FJRouteRedirectInfo]
}

extension FJRouteMatchChain {
    /// 路由匹配时的最终目的页面地类型
    public enum PageDestination: Sendable {
        case route(_ r: any FJRouteTargetType)
        case url(_ u: URL)
    }
}

extension FJRouteMatchChain {
    /// 是否已经包含重定向路由
    /// - Parameter route: 重定向路由
    /// - Returns: 结果
    func containsRedirect(route: any FJRouteTargetType) -> Bool {
        for redirect in self.redirects {
            // TODO: -
//            let rr = redirect.to
//            if rr.uri.path == route.uri.path && rr.uri.caseSensitive == rr.uri.caseSensitive {
//                return true
//            }
        }
        return false
    }
}
