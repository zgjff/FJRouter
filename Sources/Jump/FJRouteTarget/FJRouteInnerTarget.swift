//
//  FJRouteInnerTarget.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation

internal final class FJRouteInnerTarget: @unchecked Sendable {
    let target: any FJRouteTargetType
    let paretnTarget: FJRouteInnerTarget?
    private var pathParameters: [String] = []
    private var regExp: NSRegularExpression? = nil
    init(target: any FJRouteTargetType, paretnTarget: FJRouteInnerTarget?) {
        self.target = target
        self.paretnTarget = paretnTarget
    }
}

extension FJRouteInnerTarget {
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
        let parentPath = paretnTarget?.target.path ?? ""
        let fp = FJPathUtils.default.concatenatePaths(parentPath: parentPath.trimmingCharacters(in: .whitespacesAndNewlines), childPath: target.path)
        return fp
    }
}
