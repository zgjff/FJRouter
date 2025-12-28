//
//  FJRouteTargetPath.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

/// 路由path协议
public protocol FJRouteTargetPath {
    /// 路由的路径: 支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    var path: String { get }
    
    /// 路由匹配正则是否支持`NSRegularExpression.Options.caseInsensitive`
    var caseSensitive: Bool { get }
}

extension FJRouteTargetPath {
    /// 解析出匹配正则, 以及参数数组.具体的匹配数据以及测试代码可以参考: `FJPathUtilsTests`
    ///
    ///  无参数:
    ///
    ///     path为"/settings/detail", 则解析出的正则为: "^\/settings\/detail(?=/|$)", 参数数组为[]
    ///  一个参数:
    ///
    ///     path为"/user/:id", 则解析出的正则为: "^\/user\/(?<id>[^/]+)(?=/|$)", 参数数组为["id"]
    ///  多个参数:
    ///
    ///     path为"/user/:id/book/:bookId", 则解析出的正则为: "^\/user\/(?<id>[^/]+)\/book\/(?<bookId>[^/]+)(?=/|$)", 参数数组为["id", "bookId"]
    func resolveRouteInfo() throws(FJRouter.RegisterURIError) -> (regExp: NSRegularExpression, parameters: [String]) {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw FJRouter.RegisterURIError.emptyPath
        }
        do {
            let (regExp, pathParameters) = try FJPathUtils.default.patternToRegExpSync(pattern: p, caseSensitive: caseSensitive)
            return (regExp, pathParameters)
        } catch {
            throw FJRouter.RegisterURIError.regExp(error)
        }
    }
}

extension String: FJRouteTargetPath {
    public var path: String {
        self
    }
    
    public var caseSensitive: Bool {
        true
    }
}

extension FJRouteTarget {
    /// 通用path 实现
    public struct CommonPath: FJRouteTargetPath, Sendable {
        public let path: String
        public let caseSensitive: Bool
        public init(path: String, caseSensitive: Bool = true) {
            self.path = path
            self.caseSensitive = caseSensitive
        }
    }
}
