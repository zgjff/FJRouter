//
//  FJRouteMatchChain.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/19.
//

import Foundation
/// 路由匹配链路
public struct FJRouteMatchChain: @unchecked Sendable {
    /// 最初的目的路由:
    // TODO: - from Universal Links
    public let originalDestinationRoute: FJRouteChain
    /// 路由重定向
    public let redirects: [FJRouteRedirectInfo]
}

extension FJRouteMatchChain {
    /// 是否已经包含重定向路由
    /// - Parameter route: 重定向路由
    /// - Returns: 结果
    func containsRedirect(route: any FJRouteTargetType) -> Bool {
        for redirect in self.redirects {
            let rr = redirect.to.route
            if rr.path.path == route.path.path && rr.path.caseSensitive == rr.path.caseSensitive {
                return true
            }
        }
        return false
    }
}
