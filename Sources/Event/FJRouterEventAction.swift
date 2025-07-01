//
//  FJRouterEventAction.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

/// 事件
public struct FJRouterEventAction: Sendable {
    /// 事件uri
    public let uri: any FJRouterRegisterURI
    
    /// 事件path解析出来的参数名称数组
    public let pathParameters: [String]
    
    /// 对应正则表达式
    private let regExp: NSRegularExpression?
    
    public init(uri: any FJRouterRegisterURI) async throws(FJRouter.RegisterURIError) {
        (regExp, pathParameters) = try await uri.resolve()
        self.uri = uri
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
        hasher.combine(uri.path)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lreg = lhs.regExp, let rreg = rhs.regExp {
            if lreg.pattern == rreg.pattern {
                return true
            }
        }
        return lhs.uri.path == rhs.uri.path
    }
}

extension FJRouterEventAction: CustomStringConvertible, CustomDebugStringConvertible {
    public nonisolated var description: String {
        var result = "FJRouterEventAction(uri: \(uri)"
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
