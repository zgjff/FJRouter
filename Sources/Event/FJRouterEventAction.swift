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
        if let lp = regExp?.pattern {
            hasher.combine(lp)
            return
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lreg = lhs.regExp, let rreg = rhs.regExp {
            if lreg.pattern == rreg.pattern {
                return true
            }
        }
        return lhs.path == rhs.path
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
