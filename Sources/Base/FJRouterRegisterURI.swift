//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2025/6/7.
//

import Foundation

/// 注册的资源标识符协议.
///
/// 与`FJRouter.URI`相比:
/// `FJRouterRegisterURI`: 代表注册的资源, 最终在匹配时, 是通过内部解析`path`的正则以及参数数组进行的;
/// `FJRouter.URI`: 查询具体的资源的位置URI
public protocol FJRouterRegisterURI: Sendable, Equatable {
    /// 资源路径
    ///
    /// 该路径还支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    ///
    var path: String { get }
    
    /// 资源名称: 此参数可以为`nil`, 但是如果一旦设置了不为`nil`, 必须不能为空, 否则会抛出`FJRouter.RegisterURIError.emptyName`错误;
    /// 而且要保证`name`的唯一性, 否则在注册的时候会触发断言assert
    var name: String? { get }
    
    /// 重新设置资源的名称
    /// - Parameter name: 新名称
    /// - Returns: 返回相同path, 但是名称不同的资源
    func chang(name: String?) -> Self
}

extension FJRouterRegisterURI {
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
    public func resolve() async throws(FJRouter.RegisterURIError) -> (regExp: NSRegularExpression, parameters: [String]) {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw FJRouter.RegisterURIError.emptyPath
        }
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let n, n.isEmpty {
            throw FJRouter.RegisterURIError.emptyName
        }
        do {
            let (regExp, pathParameters) = try await FJPathUtils.default.patternToRegExp(pattern: p)
            return (regExp, pathParameters)
        } catch {
            throw FJRouter.RegisterURIError.regExp(error)
        }
    }
}


/// 通用路注册的资源标识符
public struct FJRouterCommonRegisterURI: FJRouterRegisterURI, CustomStringConvertible, CustomDebugStringConvertible {
    public let path: String
    public let name: String?
    
    public init(path: String, name: String? = nil) {
        self.path = path
        self.name = name
    }
    
    public func chang(name: String?) -> FJRouterCommonRegisterURI {
        FJRouterCommonRegisterURI(path: path, name: name)
    }
    
    public var description: String {
        var result = "RegisterURI(path: \(path)"
        if let name {
            result += ", name: \(name)"
        }
        result += ")"
        return "RegisterURI"
    }
    
    public var debugDescription: String {
        description
    }
}

extension FJRouter {
    public enum RegisterURIError: Error, @unchecked Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
        /// path为空
        case emptyPath
        /// 设置了空name
        case emptyName
        /// 生成正则表达式错误
        case regExp(_ error: Error)
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.emptyPath, .emptyPath):
                return true
            case (.emptyName, .emptyName):
                return true
            case (.regExp, .regExp):
                return false
            default:
                return false
            }
        }
        
        public var description: String {
            switch self {
            case .emptyPath:
                return "path不能为空"
            case .emptyName:
                return "设置了空name"
            case .regExp(let e):
                return "生成正则表达式错误: \(e)"
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
