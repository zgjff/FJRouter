//
//  FJRouterResourceAction.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/26.
//

import Foundation

/// 系统资源
public struct FJRouterResourceAction: Sendable {
    /// 资源构造器: 系统分配的任意线程中调度返回数据
    public typealias Value = (@Sendable (_ info: Int) -> (any Sendable)?)
    /// 资源构造器: 主线程调度返回数据
    public typealias MainActorValue = (@MainActor @Sendable (_ info: Int) -> (any Sendable)?)
    /// 资源名称
    public let name: String?
    
    /// 资源url匹配路径
    ///
    /// 该路径还支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    public let path: String
    
    /// 资源path解析出来的参数名称数组
    public let pathParameters: [String]
    
    internal let value: Value?
    internal let mainActorValue: MainActorValue?
    
    /// 对应正则表达式
    private let regExp: NSRegularExpression?
    
    /// 初始化
    /// - Parameters:
    ///   - path: 资源url匹配路径
    ///   - name: 资源名称
    ///   - value: 构建资源的指向: 系统分配的线程调度返回数据
    ///
    ///         let a = try FJRouterResourceAction(path: "/amodel", value: { @Sendable info in
    ///             return AModel()
    ///         })
    public init(path: String, name: String? = nil, value: @escaping Value) throws {
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
        self.value = value
        self.mainActorValue = nil
        (regExp, pathParameters) = FJPathUtils.default.patternToRegExp(pattern: p)
    }
    
    /// 初始化: value闭包内容一定是在主线程调度处理的
    /// - Parameters:
    ///   - path: 资源url匹配路径
    ///   - name: 资源名称
    ///   - value: 构建资源的指向: 主线程调度返回数据, 系统自动处理, 不用在闭包内部使用`DispatchQueue.main.async{...}`
    ///
    ///         let a = try FJRouterResourceAction(path: "/aview", mainActorValue: { @MainActor @Sendable info in
    ///             return AView()
    ///         })
    public init(path: String, name: String? = nil, mainActorValue value: @escaping MainActorValue) throws {
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
        self.mainActorValue = value
        self.value = nil
        (regExp, pathParameters) = FJPathUtils.default.patternToRegExp(pattern: p)
    }
    
    internal func matchRegExpHasPrefix(_ loc: String) -> NSRegularExpression? {
        return FJPathUtils.default.matchRegExpHasPrefix(loc, regExp: regExp)
    }
    
    internal func extractPathParameters(inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        return FJPathUtils.default.extractPathParameters(pathParameters, inString: string, useRegExp: regExp)
    }
}

extension FJRouterResourceAction: Hashable {
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

extension FJRouterResourceAction: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "FJRouterResourceAction#name:\(name == nil ? "null" : name!),path:\(path)"
    }
    
    public var debugDescription: String {
        description
    }
}

extension FJRouterResourceAction {
    public enum CreateError: Error, @unchecked Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
        case emptyPath
        case emptyName
        
        public var description: String {
            switch self {
            case .emptyPath:
                return "ResourceAction path cannot be empty"
            case .emptyName:
                return "ResourceAction name cannot be empty"
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
