//
//  FJRoute.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import UIKit

/// 路由
///
///     注意:初始化的`builder`和`redirect`参数必须至少提供一项, 否则初始化失败
///
///     参数:
///     - path: 路由路径: 如果是起始父路由, 其`path`必须以`/`为前缀
///     - name: 路由的名称: 如果赋值, 必须提供唯一的字符串名称, 且不能为空
///     - builder: 构建路由的`controller`指向
///     - animator: 显示匹配路由控制器的方式
///     - redirect: 路由重定向
///     - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头
public struct FJRoute: Sendable {
    /// 构建路由控制器
    public typealias Builder = (@MainActor @Sendable (_ info: BuilderInfo) -> UIViewController)
    
    /// 显示路由指向控制器的转场动画
    ///
    /// 框架内部提供了多种内置实现: FJRoute.XXXXAnimator
    public typealias Animator = (@MainActor @Sendable (_ info: AnimatorInfo) -> any FJRouteAnimator)
    
    /// 路由的名称
    ///
    /// 如果赋值, 必须提供唯一的字符串名称, 且不能为空
    public let name: String?
    
    /// 路由路径
    ///
    /// 注意: 如果是起始父路由, 其`path`必须以`/`为前缀
    ///
    /// 该路径还支持路径参数. eg:
    /// 路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    ///
    /// 路由参数将被解析并储存在`JJRouterState`中, 用于`builder`和`redirect`
    public let path: String
    
    /// 构建路由方式
    public let builder: FJRoute.Builder?
    
    /// 显示匹配路由控制器的方式。只适用与适用go、goNamed进行跳转的方式
    public let animator: Animator

    /// 路由拦截器
    public let redirect: (any FJRouteRedirector)?
    
    /// 路由`path`中的参数名称
    public let pathParameters: [String]
    
    /// 路由`path`的对应正则表达式
    private let regExp: NSRegularExpression?
    
    /// 关联的子路由
    public let routes: [FJRoute]
    
    /// 初始化. 注意:`builder`和`redirect`必须至少提供一项, 否则初始化失败
    /// - Parameters:
    ///   - path: 路由路径: 如果是起始父路由, 其`path`必须以`/`为前缀
    ///   - name: 路由的名称: 如果赋值, 必须提供唯一的字符串名称, 且不能为空
    ///   - builder: 构建路由的`controller`指向
    ///   - animator: 显示匹配路由控制器的方式。
    ///   - redirect: 路由重定向
    ///   - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头
    public init(path: String, name: String? = nil, builder: Builder?, animator: Animator? = nil, redirect: (any FJRouteRedirector)? = nil, routes: @autoclosure () throws -> [FJRoute] = []) throws {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw CreateError.emptyPath
        }
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let n, n.isEmpty {
            throw CreateError.emptyName
        }
        if builder == nil && redirect == nil {
            throw CreateError.noPageBuilder
        }
        do {
            self.routes = try routes()
        } catch {
            if let err = error as? CreateError {
                throw err
            }
            self.routes = []
        }
        self.path = p
        self.name = n
        self.builder = builder
        self.animator = animator ?? { @MainActor @Sendable _ in AutomaticAnimator() }
        self.redirect = redirect
        (regExp, pathParameters) = FJPathUtils.default.patternToRegExp(pattern: p)
    }
    
    internal func matchRegExpHasPrefix(_ loc: String) -> NSRegularExpression? {
        guard let regExp else {
            return nil
        }
        if regExp.firstMatch(in: loc, range: NSRange(location: 0, length: loc.count)) != nil {
            return regExp
        }
        let ploc = "/\(loc)"
        if regExp.firstMatch(in: ploc, range: NSRange(location: 0, length: ploc.count)) != nil {
            return regExp
        }
        return nil
    }
    
    internal func extractPathParameters(inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        return FJPathUtils.default.extractPathParameters(pathParameters, inString: string, useRegExp: regExp)
    }
}

extension FJRoute {
    /// 路由动画信息
    public struct BuilderInfo: Sendable {
        /// 要跳转到的源控制器
        public let fromVC: UIViewController?
        /// 匹配到的路由信息
        public let matchState: FJRouterState
    }
}

extension FJRoute: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path == rhs.path
    }
}

extension FJRoute: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "FJRoute#name:\(name == nil ? "null" : name!),path:\(path)"
    }
    
    public var debugDescription: String {
        description
    }
}

extension FJRoute {
    public enum CreateError: Error, Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
        case emptyPath
        case emptyName
        case noPageBuilder
        
        public var description: String {
            switch self {
            case .emptyPath:
                return "FJRoute path cannot be empty"
            case .emptyName:
                return "FJRoute name cannot be empty"
            case .noPageBuilder:
                return "FJRoute builder or redirect must be provided"
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
