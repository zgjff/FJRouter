//
//  FJRouteMatch.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

#if canImport(UIKit)
import Foundation
/// 路由匹配信息
internal struct FJRouteMatch: Sendable {
    /// 匹配到的路由
    let route: FJRoute
    /// 匹配到的内容字符串
    let matchedLocation: String
}

extension FJRouteMatch: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return "FJRouteMatch#(route:\(route)),matchedLocation:\(matchedLocation)"
    }
    
    var debugDescription: String {
        description
    }
}

extension FJRouteMatch {
    /// 匹配url和路由信息
    /// - Parameters:
    ///   - route: 要匹配的路由
    ///   - url: 要匹配的url
    /// - Returns: 返回匹配到的路由数组和参数
    static func match(route: FJRoute, byUrl url: URL) -> (matches: [FJRouteMatch], pathParameters: [String: String]) {
        return match(route: route, remainingLocation: url.fj.versionPath, pathParameters: [:], url: url)
    }
    
    private static func match(route: FJRoute, matchedPath: String = "", remainingLocation: String, matchedLocation: String = "", pathParameters: [String: String], url: URL) -> (matches: [FJRouteMatch], pathParameters: [String: String]) {
        guard let regExp = route.matchRegExpHasPrefix(remainingLocation) else {
            return ([], [:])
        }
        let encodedParams = route.extractPathParameters(inString: remainingLocation, useRegExp: regExp)
        let currentPathParameter = encodedParams.reduce([String: String](), { $0.merging([$1.key: $1.value.removingPercentEncoding ?? $1.value], uniquingKeysWith: { (_, new) in new })})
        guard let pathLoc = try? FJPathUtils.default.patternToPath(pattern: route.path, pathParameters: encodedParams) else {
            return ([], [:])
        }
        let newMatchedLocation = FJPathUtils.default.concatenatePaths(parentPath: matchedLocation, childPath: pathLoc)
        let matchSuccess = newMatchedLocation.lowercased() == url.fj.versionPath.lowercased()
        let finalMatchLocation = newMatchedLocation
        if matchSuccess { // 匹配成功
            let finalParameters = pathParameters.merging(currentPathParameter) { (_, new) in new }
            return ([FJRouteMatch(route: route, matchedLocation: finalMatchLocation)], finalParameters)
        }
        if route.routes.isEmpty {
            return ([], [:])
        }
        // 匹配子路由
        let newMatchedPath = FJPathUtils.default.concatenatePaths(parentPath: matchedPath, childPath: route.path)
        let childLocStartIndex = url.fj.versionPath.index(url.fj.versionPath.startIndex, offsetBy: newMatchedLocation.count + ((newMatchedLocation == "/") ? 0 : 1))
        let childLocEndIndex = url.fj.versionPath.endIndex
        let childRestLoc = String(describing: url.fj.versionPath[childLocStartIndex..<childLocEndIndex])
        
        var subRouteMatches: [FJRouteMatch] = []
        var subRoutePathParameters: [String: String] = [:]
        for subRoute in route.routes {
            (subRouteMatches, subRoutePathParameters) = match(route: subRoute, matchedPath: newMatchedPath, remainingLocation: childRestLoc, matchedLocation: newMatchedLocation, pathParameters: pathParameters, url: url)
            if !subRouteMatches.isEmpty {
                break
            }
        }
        if subRouteMatches.isEmpty {
            return ([], [:])
        }
        let finalParameters = pathParameters.merging(currentPathParameter, uniquingKeysWith: { (_, new) in new }).merging(subRoutePathParameters, uniquingKeysWith: { (_, new) in new })
        subRouteMatches.insert(FJRouteMatch(route: route, matchedLocation: newMatchedLocation), at: 0)
        return (subRouteMatches, finalParameters)
    }
}

extension FJRouteMatch: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(route)
        hasher.combine(matchedLocation)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.route == rhs.route && lhs.matchedLocation == rhs.matchedLocation
    }
}

#endif
