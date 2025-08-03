//
//  FJRouteInnerTarget.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation

extension FJRouteTarget {
    internal final class InnerTarget: @unchecked Sendable {
        let target: any FJRouteTargetType
        let paretnTarget: FJRouteTarget.InnerTarget?
        private var pathParameters: [String] = []
        private var regExp: NSRegularExpression? = nil
        init(target: any FJRouteTargetType, paretnTarget: FJRouteTarget.InnerTarget?) {
            self.target = target
            self.paretnTarget = paretnTarget
        }
    }
}

extension FJRouteTarget.InnerTarget {
    func resolve() async throws(FJRouter.RegisterURIError) -> (regExp: NSRegularExpression, pathParameters: [String]) {
        if let regExp {
            return (regExp, pathParameters)
        }
        let pairs = try await target.resolve()
        self.regExp = pairs.regExp
        self.pathParameters = pairs.pathParameters
        return (pairs.regExp, pairs.pathParameters)
    }
    
    func fullpath() -> String {
        // TODO: - 一直查找parentPath
        let parentPath = paretnTarget?.target.path ?? ""
        let fp = FJPathUtils.default.concatenatePaths(parentPath: parentPath.trimmingCharacters(in: .whitespacesAndNewlines), childPath: target.path)
        return fp
    }
    
    static func allRoutes(for target: any FJRouteTargetType) async -> [FJRouteTarget.InnerTarget] {
        return await withCheckedContinuation { continuation in
            let rs = FJRouteTarget.InnerTarget.routes(target, parentInnerTarget: nil, subRouteDepth: 1)
            let fs = rs.enumerated().filter({ (index, ele1) in
                return rs.firstIndex(where: { ele2 in
                    return ele1.target.path == ele2.target.path && ele1.target.name == ele2.target.name
                }) == index
            }).map { $0.element }
            continuation.resume(returning: fs)
        }
    }

    private static func routes(_ target: any FJRouteTargetType, parentInnerTarget: FJRouteTarget.InnerTarget?, subRouteDepth: Int) -> [FJRouteTarget.InnerTarget] {
        if subRouteDepth >= 66 {
            return []
        }
        let currentIt = FJRouteTarget.InnerTarget(target: target, paretnTarget: parentInnerTarget)
        var allTargets = [currentIt]
        for subTarget in target.subTargets {
            let srs = routes(subTarget, parentInnerTarget: currentIt, subRouteDepth: subRouteDepth + 1)
            if !srs.isEmpty {
                allTargets.append(contentsOf: srs)
            }
        }
        return allTargets
    }
}

extension FJRouteTarget.InnerTarget: Equatable {
    static func == (lhs: FJRouteTarget.InnerTarget, rhs: FJRouteTarget.InnerTarget) -> Bool {
        return lhs.target.path == rhs.target.path
    }
}
