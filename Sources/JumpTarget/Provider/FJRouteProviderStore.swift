//
//  FJRouteProviderStore.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

final actor FJRouteProviderStore {
    private var routes: [any FJRouteTargetType]
    
    init() {
        routes = []
        routes.reserveCapacity(50)
    }
}

extension FJRouteProviderStore {
    func addRoute(_ route: any FJRouteTargetType) {
        checkRoutePath([route])
        checkNoDuplicatePathParameter([route], usedPathParams: [:])
        routes.append(route)
    }
    
    func aaaa() {
        
    }
}

private extension FJRouteProviderStore  {
    /// 检查路由path是否符合约定
    func checkRoutePath(_ routes: [any FJRouteTargetType]) {
        for route in routes {
            let rp = route.path.path
            assert(!rp.isEmpty, "\(String(describing: route)) 路由path不能为空")
            if rp != "/" {
                assert(!rp.hasSuffix("/"), "除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾. 当前路由: \(String(describing: route))")
            }
            checkRoutePath(route.subTargets)
        }
    }
    
    /// 检查路由及其子路由是否存在相同的路由参数
    /// - Parameters:
    ///   - routes: 路由
    ///   - usedPathParams: [参数key: 路由]
    func checkNoDuplicatePathParameter(_ routes: [any FJRouteTargetType], usedPathParams: [String: any FJRouteTargetType]) {
        var p = usedPathParams
        for route in routes {
            for ppk in route.pathParams.keys {
                if p.keys.contains(ppk) {
                    let sameRoute = p[ppk]
                    assert(false, "在路由: \(String(describing: sameRoute))及其子路由: \(String(describing: route))中发现重复的路由参数: \(ppk)")
                }
                p.updateValue(route, forKey: ppk)
            }
            checkNoDuplicatePathParameter(route.subTargets, usedPathParams: p)
            route.pathParams.keys.forEach { k in
                p.removeValue(forKey: k)
            }
        }
    }
}
