//
//  FJRouteJumpProviderStore.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/16.
//

import Foundation

final actor FJRouteJumpProviderStore {
    private var routes: [FJRouteTarget.InnerTarget]
    private let config: FJRouteJumpProviderConfig
    nonisolated let unownedExecutor: UnownedSerialExecutor
    init(config: FJRouteJumpProviderConfig) {
        unownedExecutor = FJRouteActor.sharedUnownedExecutor
        self.config = config
        routes = []
        routes.reserveCapacity(64)
    }
}

extension FJRouteJumpProviderStore {
    @discardableResult
    func addRoute(_ route: any FJRouteTargetType) throws(FJRouteTarget.RegisterError) -> FJRouteTarget.InnerTarget {
        let ir = try FJRouteTarget.InnerTarget(originalTarget: route, assertErrorInDebug: config.assertRegisterErrorInDebug)
        guard let pr = route.parent else {
            routes.append(ir)
            return ir
        }
        // 检测pr是否已经注册
        if let pir = findInnerTarget(for: pr) {
            // 已注册
            try ir.tryAddParent(ptarget: pir, assertErrorInDebug: config.assertRegisterErrorInDebug)
            return ir
        }
        // 没注册
        let pir = try addRoute(pr)
        try ir.tryAddParent(ptarget: pir, assertErrorInDebug: config.assertRegisterErrorInDebug)
        return ir
    }
    
    func matchRoute(_ route: any FJRouteTargetType) async throws(FJRouteMatchError) {
        
    }
}

private extension FJRouteJumpProviderStore {
    
}

private extension FJRouteJumpProviderStore {
    func findInnerTarget(for route: any FJRouteTargetType) -> FJRouteTarget.InnerTarget? {
        for r in routes {
            if let frt = r.find(target: route) {
                return frt
            }
        }
        return nil
    }
    
    // TODO: - 返回result
    func tryRedirect(routeChain: FJRouteChain) async throws(FJRouteMatchError) -> FJRouteMatchChain {
        return FJRouteMatchChain(originalDestinationRoute: routeChain, redirects: [])
//        var matchChain = FJRouteMatchChain(originalDestinationRoute: routeChain, redirects: [])
//        var rps = Array(routeChain.parents.reversed())
//        var proute = rps.popLast()
//        while let pr = proute {
//            // TODO: - 优先级排序
//            var pinterceptors = pr.interceptors.sorted(by: { $0.priority < $1.priority })
//            var pi = pinterceptors.popLast()
//            while let p = pi {
//                let action = await p.onActive(route: pr, chain: matchChain)
//                switch action {
//                case .guard:
//                    // TODO: - 不执行任何动作, 直接返回错误
//                    break
//                case .pass:
//                    pi = pinterceptors.popLast()
//                case let .redirect(nr):
//                    if matchChain.containsRedirect(route: nr) {
//                        // TODO: - 返回错误
//                        
//                    }
//                    // TODO: - check redirect数量
//                    guard let findInnerTarget = findInnerTarget(for: nr) else {
//                        // TODO: - 返回错误
//                        break
//                    }
//                    let fr = findInnerTarget.routeChain()
//                    // TODO: - catch error
//                    let redirectChain = try await tryRedirect(routeChain: fr)
//                    let newMatchChain = FJRouteMatchChain(originalDestinationRoute: routeChain, redirects: [
//                        FJRouteRedirectInfo(from: pr, to: fr),
//                    ])
//                    matchChain = newMatchChain
//                    // TODO: - 直接返回
//                }
//            }
//            proute = rps.popLast()
//        }
    }
}
