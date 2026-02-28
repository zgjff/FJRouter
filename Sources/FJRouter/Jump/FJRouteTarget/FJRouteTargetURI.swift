//
//  FJRouteTargetURI.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

/// 路由uri协议
///
/// 为了一致性保障, 请实现此协议的对象遵守`Identifiable`, 且其`ID`类型为`UUID`;
///
/// 需要确保其`id`在整个生命周期内多次获取时保障一致性, 不会重新生成。
///
/// 可以使用框架提供的默认实现: `FJRouteTarget.CommonURI`
public protocol FJRouteTargetURI: Identifiable where ID == UUID {
    /// 路由的路径: 支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    var path: String { get }
    
    /// 路由匹配正则是否支持`NSRegularExpression.Options.caseInsensitive`
    var caseSensitive: Bool { get }
}

extension FJRouteTargetURI {
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
    func resolveRouteInfo() throws(FJRouteTarget.RegisterURIError) -> (regExp: NSRegularExpression, parameters: [String]) {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw FJRouteTarget.RegisterURIError.emptyPath
        }
        do {
            let (regExp, pathParameters) = try FJPathUtils.default.patternToRegExp(pattern: p, caseSensitive: caseSensitive)
            return (regExp, pathParameters)
        } catch {
            throw FJRouteTarget.RegisterURIError.regExp(error)
        }
    }
}

extension FJRouteTarget {
    /// 注册路由uri错误
    public enum RegisterURIError: Error {
        /// path为空
        case emptyPath
        /// 生成正则表达式错误
        case regExp(_ error: Error)
    }
}

extension FJRouteTarget {
    /// 通用URI 实现
    public struct CommonURI: FJRouteTargetURI, Sendable, Hashable {
        public let path: String
        public let caseSensitive: Bool
        public let id: UUID
        public init(path: String, caseSensitive: Bool = true) {
            self.path = path
            self.caseSensitive = caseSensitive
            id = UUID()
        }
    }
}
