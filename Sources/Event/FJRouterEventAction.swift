//
//  FJRouterEventAction.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

/// 事件
public struct FJRouterEventAction: Sendable {
    /// 事件名称
    public let name: String?
    
    /// 事件url匹配路径
    ///
    /// 该路径还支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    public let path: String
    
    /// 事件path解析出来的参数名称数组
    public let pathParameters: [String]
    
    /// 对应正则表达式
    private let regExp: NSRegularExpression?
    
    public init(path: String, name: String? = nil) throws(FJRouterEventAction.CreateError) {
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
        hasher.combine(path)
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
    public nonisolated var description: String {
        var result = "FJRouterEventAction(path: \(path)"
        if let name {
            result.append(", name: \(name)")
        }
        if !pathParameters.isEmpty {
            result.append(", pathParameters: \(pathParameters)")
        }
        result += ")"
        return result
    }
    
    public var debugDescription: String {
        description
    }
}

extension FJRouterEventAction {
    public enum CreateError: Error, @unchecked Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
        case emptyPath
        case emptyName
        
        public nonisolated var description: String {
            switch self {
            case .emptyPath:
                return "EventAction path cannot be empty"
            case .emptyName:
                return "EventAction name cannot be empty"
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
