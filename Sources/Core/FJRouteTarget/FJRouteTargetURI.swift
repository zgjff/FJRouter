//
//  FJRouteTargetURI.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

/// 路由uri协议
///
/// 为了一致性保障, 请实现此协议的对象遵守`Identifiable`, 且其`ID`类型为`String`;
///
/// 需要确保其`id`在整个生命周期内多次获取时保障一致性, 不会重新生成。
///
/// 可以使用框架提供的默认实现: `FJRouteTarget.CommonURI`
public protocol FJRouteTargetURI: Identifiable where ID == String {
    /// 路由的路径: 支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    var path: String { get }
    
    /// 路由匹配正则是否支持`NSRegularExpression.Options.caseInsensitive`
    ///
    /// true: 不区分大小写
    ///
    /// false: 区分大小写
    var caseSensitive: Bool { get }
    
    /// 路由的名称
    var name: String? { get }
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

    /// 判断两个uri的path是否相等
    /// - Parameter other: 要匹配的uri
    /// - Returns: 结果
    func equtalPath(to other: any FJRouteTargetURI) -> Bool {
        switch (caseSensitive, other.caseSensitive) {
        case (false, false): // 都区分大小写
            return path == other.path
        case (true, true): // 都不区分大小写
            return path.caseInsensitiveCompare(other.path) == .orderedSame
        case (true, false):
            let v = path.caseInsensitiveCompare(other.path)
            return v == .orderedSame
        case (false, true):
            let v = other.path.caseInsensitiveCompare(path)
            return v == .orderedSame
        }
    }
}

extension FJRouteTarget {
    /// 注册路由uri错误
    public enum RegisterURIError: @unchecked Sendable, Error, Equatable {
        /// path为空
        case emptyPath
        /// 生成正则表达式错误
        case regExp(_ error: Error)
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.emptyPath, .emptyPath):
                return true
            case (.regExp, .regExp):
                return true
            case (.emptyPath, .regExp), (.regExp, .emptyPath):
                return false
            }
        }
    }
}

extension FJRouteTarget {
    /// 通用URI 实现
    public struct CommonURI: FJRouteTargetURI, Sendable, Hashable {
        public let path: String
        public let caseSensitive: Bool
        public let name: String?
        public let id: String
        
        /// 初始化
        /// - Parameters:
        ///   - path: path
        ///   - caseSensitive: 路由匹配正则是否支持`NSRegularExpression.Options.caseInsensitive`大小写. true: 不区分大小写, false: 区分大小写
        ///   - idTransform: 转换id, 默认`id = String(describing: fileId) + ":\(line)"`
        ///   - fileId: file ID
        ///   - line: line
        public init(path: String, caseSensitive: Bool = true, name: String?, idTransform: (_ value: String) -> String = { $0 }, fileId: StaticString = #fileID, line: UInt = #line) {
            let fidstr = String(describing: fileId) + ":\(line)"
            id = idTransform(fidstr)
//            if path == "/" {
//                self.path = path
//            } else {
//                self.path = path.hasPrefix("/") ? path : "/\(path)"
//            }
            self.path = path
            self.caseSensitive = caseSensitive
            self.name = name
        }
    }
}
