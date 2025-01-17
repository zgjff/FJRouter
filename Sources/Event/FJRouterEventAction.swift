//
//  FJRouterEventAction.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation


public struct FJRouterEventAction: Sendable {
    public let name: String?
    public let path: String
    public let pathParameters: [String]
    /// 路由`path`的对应正则表达式
    private let regExp: NSRegularExpression?
    
    public init(path: String, name: String?) {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.path = p
        self.name = n
        (regExp, pathParameters) = FJPathUtils.default.patternToRegExp(pattern: p)
    }
    
    internal func matchRegExpHasPrefix(_ loc: String) -> NSRegularExpression? {
        guard let regExp else {
            return nil
        }
        if regExp.firstMatch(in: loc, range: NSRange(location: 0, length: loc.count)) != nil {
            return regExp
        }
        let ploc = "/\(loc)"
        if regExp.firstMatch(in: ploc, range: NSRange(location: 0, length: ploc.count)) != nil {
            return regExp
        }
        return nil
    }
    
    internal func extractPathParameters(inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        return FJPathUtils.default.extractPathParameters(pathParameters, inString: string, useRegExp: regExp)
    }
}

extension FJRouterEventAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(name)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
        && lhs.name == rhs.name
    }
}

extension FJRouterEventAction: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "FJRouterEventAction#name:\(name == nil ? "null" : name!),path:\(path)"
    }
    
    public var debugDescription: String {
        description
    }
}
