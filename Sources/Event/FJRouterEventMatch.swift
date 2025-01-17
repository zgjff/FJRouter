//
//  FJRouterEventMatch.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 事件匹配信息
    internal struct EventMatch: Sendable {
        /// 匹配到的action
        let action: FJRouterEventAction
        /// 匹配到的内容字符串
        let matchedLocation: String
    }
}

extension FJRouter.EventMatch {
    static func match(action: FJRouterEventAction, byUrl url: URL) -> (match: FJRouter.EventMatch, pathParameters: [String: String])? {
        let remainingLocation = url.versionPath
        guard let regExp = action.matchRegExpHasPrefix(remainingLocation) else {
            return nil
        }
        let encodedParams = action.extractPathParameters(inString: remainingLocation, useRegExp: regExp)
        let currentPathParameter = encodedParams.reduce([String: String](), { $0.merging([$1.key: $1.value.removingPercentEncoding ?? $1.value], uniquingKeysWith: { (_, new) in new })})
        let pathLoc = FJPathUtils.default.patternToPath(pattern: action.path, pathParameters: encodedParams)
        let newMatchedLocation = FJPathUtils.default.concatenatePaths(parentPath: "", childPath: pathLoc)
        
        var matchSuccess = newMatchedLocation.lowercased() == url.versionPath.lowercased()
        var finalMatchLocation = newMatchedLocation
        if !matchSuccess {
            if newMatchedLocation.hasSuffix("/") {
                let dnp = newMatchedLocation.dropFirst()
                if dnp.lowercased() == url.versionPath.lowercased() {
                    matchSuccess = true
                    finalMatchLocation = String(dnp)
                }
            }
        }
        if !matchSuccess {
            if !newMatchedLocation.hasPrefix("/") {
                if (newMatchedLocation.lowercased() + "/") == url.versionPath.lowercased() {
                    matchSuccess = true
                }
            }
        }
        if !matchSuccess {
            if newMatchedLocation.hasPrefix("/") {
                let dnp = newMatchedLocation.dropFirst()
                if dnp.lowercased() == ((url.versionPath.lowercased() + "/")) {
                    matchSuccess = true
                    finalMatchLocation = String(dnp)
                }
            }
        }
        if !matchSuccess {
            if newMatchedLocation.hasPrefix("/") {
                let dnp = newMatchedLocation.dropFirst() + "/"
                if dnp.lowercased() == url.versionPath.lowercased() {
                    matchSuccess = true
                    finalMatchLocation = String(dnp)
                }
            }
        }
        if !matchSuccess {
            let np = newMatchedLocation + "/"
            if np.lowercased() == url.versionPath.lowercased() {
                matchSuccess = true
                finalMatchLocation = np
            }
        }
        if !matchSuccess {
            if newMatchedLocation.lowercased() == ((url.versionPath.lowercased() + "/")) { // 匹配成功
                matchSuccess = true
            }
        }
        if !matchSuccess {
            if !newMatchedLocation.hasPrefix("/") {
                if (newMatchedLocation.lowercased() + "/") == url.versionPath.lowercased() {
                    matchSuccess = true
                }
            }
        }
        if matchSuccess { // 匹配成功
            return (.init(action: action, matchedLocation: finalMatchLocation), currentPathParameter)
        }
        return nil
    }
}

extension FJRouter.EventMatch: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return "FJRouterEventMatch#(route:\(action)),matchedLocation:\(matchedLocation)"
    }
    
    var debugDescription: String {
        description
    }
}

extension FJRouter.EventMatch: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(action)
        hasher.combine(matchedLocation)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.action == rhs.action && lhs.matchedLocation == rhs.matchedLocation
    }
}
