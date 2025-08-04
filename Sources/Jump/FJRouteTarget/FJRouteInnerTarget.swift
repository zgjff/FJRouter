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
        private var pchildrenTargets: [FJRouteTarget.InnerTarget]?
        private var pathParameters: [String] = []
        private var regExp: NSRegularExpression? = nil
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
    
    func fullpath() -> String {
        // TODO: - 一直查找parentPath
        let parentPath = parentTarget?.target.path ?? ""
        let fp = FJPathUtils.default.concatenatePaths(parentPath: parentPath.trimmingCharacters(in: .whitespacesAndNewlines), childPath: target.path)
        return fp
    }
    
    func childrenTargets() -> [FJRouteTarget.InnerTarget] {
        if let pchildrenTargets {
            return pchildrenTargets
        }
        let cts = target.subTargets.map { FJRouteTarget.InnerTarget(target: $0, parentTarget: self, subDepth: subDepth + 1) }
        self.pchildrenTargets = cts
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
