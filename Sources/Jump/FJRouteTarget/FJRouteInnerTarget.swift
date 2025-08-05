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
        let parentTarget: FJRouteTarget.InnerTarget?
        private let subDepth: Int
        private var p_childrenTargets: [FJRouteTarget.InnerTarget]?
        private var pathParameters: [String] = []
        private var regExp: NSRegularExpression? = nil
        private var p_fullpath: String?
        init(target: any FJRouteTargetType) {
            self.target = target
            self.parentTarget = nil
            subDepth = 0
        }
        
        private init(target: any FJRouteTargetType, parentTarget: InnerTarget?, subDepth: Int) {
            self.target = target
            self.parentTarget = parentTarget
            self.subDepth = subDepth
        }
    }
}

extension FJRouteTarget.InnerTarget {
    func resolve() async throws(FJRouter.RegisterURIError) -> (regExp: NSRegularExpression, pathParameters: [String], exsits: Bool) {
        if let regExp {
            return (regExp, pathParameters, true)
        }
        let pairs = try await target.resolve()
        self.regExp = pairs.regExp
        self.pathParameters = pairs.pathParameters
        return (pairs.regExp, pairs.pathParameters, false)
    }
    
    func fullpath() async -> String {
        if let p_fullpath {
            return p_fullpath
        }
        return await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: "")
                return
            }
            var p = self.target.path
            var paths: [String] = []
            var pt = self.parentTarget
            while pt != nil {
                paths.append(pt!.target.path)
                pt = pt?.parentTarget
            }
            while let lp = paths.popLast() {
                p = FJPathUtils.default.concatenatePaths(parentPath: lp, childPath: p)
            }
            self.p_fullpath = p
            continuation.resume(returning: p)
            return
        }
    }
    
    func childrenTargets() -> [FJRouteTarget.InnerTarget] {
        if let p_childrenTargets {
            return p_childrenTargets
        }
        if subDepth > 33 {
            return []
        }
        let cts = target.subTargets.map { FJRouteTarget.InnerTarget(target: $0, parentTarget: self, subDepth: subDepth + 1) }
        self.p_childrenTargets = cts
        return cts
    }
    
    func routeDepth() -> Int {
        subDepth
    }
}

extension FJRouteTarget.InnerTarget: Equatable {
    static func == (lhs: FJRouteTarget.InnerTarget, rhs: FJRouteTarget.InnerTarget) -> Bool {
        return lhs.target.path == rhs.target.path && lhs.target.name == rhs.target.name
    }
}
