//
//  FJRoute.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

#if canImport(UIKit)
import Foundation
import UIKit

/// 路由
///
///     注意:初始化的`builder`和`redirect`参数必须至少提供一项, 否则初始化失败
///
///     参数:
///     - uri: 资源标志
///     - builder: 构建路由的`controller`指向
///     - animator: 显示匹配路由控制器的方式
///     - redirect: 路由拦截器: 数组, 可以添加多个, 按顺序检查
///     - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头
public struct FJRoute: Sendable {
    /// 构建路由控制器
    ///
    /// 可以根据路由信息`BuilderInfo`返回对应的控制器
    public typealias Builder = @MainActor @Sendable (_ info: BuilderInfo) -> UIViewController
    
    /// 显示路由指向控制器的转场动画
    ///
    /// 框架内部提供了多种内置实现: FJRoute.XXXXAnimator
    public typealias Animator = @MainActor @Sendable (_ info: AnimatorInfo) -> any FJRouteAnimator

    /// 资源标志
    public let uri: any FJRouterRegisterURI
    
    /// 构建路由方式
    public let builder: FJRoute.Builder?
    
    /// 显示匹配路由控制器的方式。只适用与适用go、goNamed进行跳转的方式
    public let animator: Animator

    /// 路由拦截器: 数组, 可以添加多个, 按顺序检查
    ///
    /// 比如:
    /// 登录检查, 用户权限检查......多个条件重定向逻辑可以分开写.
    ///
    /// 职能单一, 方便测试
    public let redirect: @Sendable () -> [any FJRouteRedirector]
    
    /// 路由`path`中解析出来的参数名称数组
    public let pathParameters: [String]
    
    /// 路由`path`的对应正则表达式
    private let regExp: NSRegularExpression?
    
    /// 关联的子路由
    public let routes: [FJRoute]
    
    /// 初始化. 注意:`builder`和`redirect`必须至少提供一项, 否则初始化失败
    /// - Parameters:
    ///   - path: 路由路径: 如果是起始父路由, 其`path`必须以`/`为前缀
    ///   - name: 路由的名称: 如果赋值, 必须提供唯一的字符串名称, 且不能为空
    ///   - builder: 构建路由的`controller`指向, 数组, 可以添加多个, 按顺序检查.比如:登录检查, 用户权限检查......多个条件重定向逻辑可以分开写.
    ///   - animator: 显示匹配路由控制器的方式。不传的时候使用, `FJRoute.AutomaticAnimator`
    ///   - redirect: 路由拦截器: 数组, 可以添加多个, 按顺序检查
    ///   - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头。直接在数组前面`await`即可
    public init(path: String, name: String? = nil, builder: Builder?, animator: Animator? = nil, redirect: @escaping @autoclosure @Sendable () -> [any FJRouteRedirector] = [], routes: @autoclosure () async throws(FJRoute.CreateError) -> [FJRoute] = []) async throws(FJRoute.CreateError) {
        if builder == nil && redirect().isEmpty {
            throw CreateError.noPageBuilder
        }
        let uri = FJRouterCommonRegisterURI(path: path, name: name)
        do {
            let (regExp, pathParameters) = try await uri.resolve()
            self.uri = uri
            self.regExp = regExp
            self.pathParameters = pathParameters
            self.builder = builder
            self.animator = animator ?? { @MainActor @Sendable _ in AutomaticAnimator() }
            self.redirect = redirect
        } catch {
            throw FJRoute.CreateError.uri(error)
        }
        self.routes = try await routes()
    }
    
    /// 初始化. 注意:`builder`和`redirect`必须至少提供一项, 否则初始化失败
    /// - Parameters:
    ///   - uri: 路由注册资源
    ///   - builder: 构建路由的`controller`指向, 数组, 可以添加多个, 按顺序检查.比如:登录检查, 用户权限检查......多个条件重定向逻辑可以分开写.
    ///   - animator: 显示匹配路由控制器的方式。
    ///   - redirect: 路由拦截器: 数组, 可以添加多个, 按顺序检查
    ///   - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头。直接在数组前面`await`即可
    public init(uri: any FJRouterRegisterURI, builder: Builder?, animator: Animator? = nil, redirect: @escaping @autoclosure @Sendable () -> [any FJRouteRedirector] = [], routes: @autoclosure () async throws(FJRoute.CreateError) -> [FJRoute] = []) async throws(FJRoute.CreateError) {
        if builder == nil && redirect().isEmpty {
            throw CreateError.noPageBuilder
        }
        do {
            let (regExp, pathParameters) = try await uri.resolve()
            self.uri = uri
            self.regExp = regExp
            self.pathParameters = pathParameters
            self.builder = builder
            self.animator = animator ?? { @MainActor @Sendable _ in AutomaticAnimator() }
            self.redirect = redirect
        } catch {
            throw FJRoute.CreateError.uri(error)
        }
        self.routes = try await routes()
    }
    
    internal func matchRegExpHasPrefix(_ loc: String) -> NSRegularExpression? {
        return FJPathUtils.default.matchRegExpHasPrefix(loc, regExp: regExp)
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

extension FJRoute: CustomStringConvertible, CustomDebugStringConvertible {
    public nonisolated var description: String {
        var result = "FJRoute(uri: \(uri)"
        if !pathParameters.isEmpty {
            result.append(", pathParameters: \(pathParameters)")
        }
        result += ")"
        return result
    }
    
    public nonisolated var debugDescription: String {
        description
    }
}

extension FJRoute {
    public enum CreateError: Error, @unchecked Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
        case uri(FJRouter.RegisterURIError)
        case noPageBuilder
        
        public var description: String {
            switch self {
            case .uri(let err):
                return err.localizedDescription
            case .noPageBuilder:
                return "builder or redirect必须提供一个"
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

#endif
