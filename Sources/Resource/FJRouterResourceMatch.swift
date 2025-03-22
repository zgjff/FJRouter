//
//  FJRouterResourceMatch.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/28.
//

import Foundation

extension FJRouter {
    /// 资源匹配信息
    internal struct ResourceMatch: Sendable {
        /// 匹配到的资源
        let resource: FJRouterResource
        /// 匹配到的内容字符串
        let matchedLocation: String
    }
}

extension FJRouter.ResourceMatch {
    static func match(resource: FJRouterResource, byUrl url: URL) -> (match: FJRouter.ResourceMatch, pathParameters: [String: String])? {
        let remainingLocation = url.versionPath
        guard let regExp = resource.matchRegExpHasPrefix(remainingLocation) else {
            return nil
        }
        let encodedParams = resource.extractPathParameters(inString: remainingLocation, useRegExp: regExp)
        let currentPathParameter = encodedParams.reduce([String: String](), { $0.merging([$1.key: $1.value.removingPercentEncoding ?? $1.value], uniquingKeysWith: { (_, new) in new })})
        guard let pathLoc = try? FJPathUtils.default.patternToPath(pattern: resource.path, pathParameters: encodedParams) else {
            return nil
        }
        let newMatchedLocation = FJPathUtils.default.concatenatePaths(parentPath: "", childPath: pathLoc)
        
        let matchSuccess = newMatchedLocation.lowercased() == url.versionPath.lowercased()
        let finalMatchLocation = newMatchedLocation
        if matchSuccess { // 匹配成功
            return (.init(resource: resource, matchedLocation: finalMatchLocation), currentPathParameter)
        }
        return nil
    }
}

extension FJRouter.ResourceMatch: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return "FJRouterResourceMatch#(resource:\(resource)),matchedLocation:\(matchedLocation)"
    }
    
    var debugDescription: String {
        description
    }
}

extension FJRouter.ResourceMatch: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(resource)
        hasher.combine(matchedLocation)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.resource == rhs.resource && lhs.matchedLocation == rhs.matchedLocation
    }
}
