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
    
    public init(path: String, name: String? = nil) throws {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw CreateError.emptyPath
        }
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let n, n.isEmpty {
            throw CreateError.emptyName
        }
        self.path = p
        self.name = n
        (regExp, pathParameters) = FJPathUtils.default.patternToRegExp(pattern: p)
    }
    
    internal func matchRegExpHasPrefix(_ loc: String) -> NSRegularExpression? {
        return FJPathUtils.default.matchRegExpHasPrefix(loc, regExp: regExp)
    }
    
    internal func extractPathParameters(inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        return FJPathUtils.default.extractPathParameters(pathParameters, inString: string, useRegExp: regExp)
    }
}

extension FJRouterEventAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        if path.isEmpty {
            hasher.combine(path)
            return
        }
        if path == "/" {
            hasher.combine(path)
            return
        }
        var p = path
        if p.hasPrefix("/") {
            p = String(p.dropFirst())
        }
        if p.hasSuffix("/") {
            p = String(p.dropLast())
        }
        hasher.combine(p)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lreg = lhs.regExp, let rreg = rhs.regExp {
            if lreg.pattern == rreg.pattern {
                return true
            }
        }
        if lhs.path == rhs.path {
            return true
        }
        var lp = lhs.path
        if lp.hasPrefix("/") {
            lp = String(lp.dropFirst())
        }
        if lp.hasSuffix("/") {
            lp = String(lp.dropLast())
        }
        var rp = rhs.path
        if rp.hasPrefix("/") {
            rp = String(rp.dropFirst())
        }
        if rp.hasSuffix("/") {
            rp = String(rp.dropLast())
        }
        return lp == rp
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

extension FJRouterEventAction {
    public enum CreateError: Error, Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
        case emptyPath
        case emptyName
        
        public var description: String {
            switch self {
            case .emptyPath:
                return "FJRoute path cannot be empty"
            case .emptyName:
                return "FJRoute name cannot be empty"
            }
        }
        
        public var debugDescription: String {
            description
        }
        
        public var errorDescription: String? {
            description
        }
        
        public var localizedDescription: String {
            description
        }
    }
}
