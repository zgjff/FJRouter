//
//  FJRouteProviderRouteStore.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/16.
//

import Foundation

final actor FJRouteProviderRouteStore {
    private var routes: [FJRouteTarget.InnerTargetType]
    
    nonisolated let unownedExecutor: UnownedSerialExecutor
    init() {
        unownedExecutor = FJRouteActor.sharedUnownedExecutor
        routes = []
        routes.reserveCapacity(64)
    }
}

extension FJRouteProviderRouteStore {
    func addRoute(_ route: any FJRouteTargetType) {
        do {
            let ir = try FJRouteTarget.InnerTargetType(originalTarget: route)
            routes.append(ir)
        } catch {
            // TODO: - throws
        }
    }
    
    func matchRoute(_ route: any FJRouteTargetType) async {
        guard let findInnerTarget = findInnerTarget(for: route) else {
            return
        }
        let chain = findInnerTarget.routeChain()
        let a = await tryRedirect(routeChain: chain)
    }
}

private extension FJRouteProviderRouteStore {
    func findInnerTarget(for route: any FJRouteTargetType) -> FJRouteTarget.InnerTargetType? {
        for r in routes {
            if let frt = r.find(target: route) {
                return frt
            }
        }
        return nil
    }
    
    // TODO: - 返回result
    func tryRedirect(routeChain: FJRouteChain) async -> FJRouteMatchChain {
        if routeChain.parents.isEmpty {
            return FJRouteMatchChain(originalDestinationRoute: routeChain, redirects: [])
        }
        var matchChain = FJRouteMatchChain(originalDestinationRoute: routeChain, redirects: [])
        var rps = Array(routeChain.parents.reversed())
        var proute = rps.popLast()
        while let pr = proute {
            // TODO: - 优先级排序
            var pinterceptors = pr.interceptors.sorted(by: { $0.priority < $1.priority })
            var pi = pinterceptors.popLast()
            while let p = pi {
                let action = await p.onActive(route: pr, chain: matchChain)
                switch action {
                case .guard:
                    // TODO: - 不执行任何动作, 直接返回错误
                    break
                case .pass:
                    pi = pinterceptors.popLast()
                case let .redirect(nr):
                    if matchChain.containsRedirect(route: nr) {
                        // TODO: - 返回错误
                        
                    }
                    // TODO: - check redirect数量
                    guard let findInnerTarget = findInnerTarget(for: nr) else {
                        // TODO: - 返回错误
                        break
                    }
                    let fr = findInnerTarget.routeChain()
                    let redirectChain = await tryRedirect(routeChain: fr)
                    let newMatchChain = FJRouteMatchChain(originalDestinationRoute: routeChain, redirects: [
                        FJRouteRedirectInfo(from: pr, to: fr),
                    ])
                    matchChain = newMatchChain
                    // TODO: - 直接返回
                }
            }
            proute = rps.popLast()
        }
        return matchChain
    }
}
