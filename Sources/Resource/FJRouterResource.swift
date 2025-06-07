//
//  FJRouterResource.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/26.
//

import Foundation

/// 资源
public struct FJRouterResource: Sendable {
    /// 资源构造器
    public typealias Value = (@Sendable (_ info: FJRouter.ResourceMatchInfo) -> (any Sendable))

    /// 资源uri
    public let uri: any FJRouterRegisterURI
    
    /// 资源path解析出来的参数名称数组
    public let pathParameters: [String]
    
    internal let value: Value
    
    /// 对应正则表达式
    private let regExp: NSRegularExpression?
    
    /// 初始化
    /// - Parameters:
    ///   - path: 资源url匹配路径
    ///   - name: 资源名称
    ///   - value: 构建资源的指向
    ///
    ///         let a = try FJRouterResource(path: "/amodel", name: "xxxx", value: { @Sendable info -> AModel? in
    ///             return info.xxxx ? AModel() : nil
    ///         })
    public init(path: String, name: String? = nil, value: @escaping Value) throws(FJRouter.RegisterURIError) {
        try self.init(uri: FJRouterCommonRegisterURI(path: path, name: name), value: value)
    }
    
    /// 初始化
    /// - Parameters:
    ///   - uri: 资源uri
    ///   - value: 构建资源的指向
    ///
    ///         let a = try FJRouterResource(uri: xxxxx, value: { @Sendable info -> AModel? in
    ///             return info.xxxx ? AModel() : nil
    ///         })
    public init(uri: any FJRouterRegisterURI, value: @escaping Value) throws(FJRouter.RegisterURIError) {
        (regExp, pathParameters) = try uri.resolve()
        self.uri = uri
        self.value = value
    }
    
    internal func matchRegExpHasPrefix(_ loc: String) -> NSRegularExpression? {
        return FJPathUtils.default.matchRegExpHasPrefix(loc, regExp: regExp)
    }
    
    internal func extractPathParameters(inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        return FJPathUtils.default.extractPathParameters(pathParameters, inString: string, useRegExp: regExp)
    }
}

extension FJRouterResource: Hashable {
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

extension FJRouterResource: CustomStringConvertible, CustomDebugStringConvertible {
    public nonisolated var description: String {
        var result = "FJRouterResourceAction(uri: \(uri)"
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
