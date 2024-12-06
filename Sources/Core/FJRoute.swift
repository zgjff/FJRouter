//
//  FJRoute.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import UIKit

/// 路由
///
///     注意:初始化的`builder`和`interceptor`参数必须至少提供一项, 否则初始化失败
///
///     参数:
///     - path: 路由路径: 如果是起始父路由, 其`path`必须以`/`为前缀
///     - name: 路由的名称: 如果赋值, 必须提供唯一的字符串名称, 且不能为空
///     - builder: 构建路由的`controller`指向
///     - displayBuilder: 构建+显示路由的`controller`指向
///     - interceptor: 路由拦截器
///     - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头
public struct FJRoute: Sendable {
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

    /// 路由拦截器
    public let interceptor: (any FJRouteInterceptor)?
    
    /// 路由`path`中的参数名称
    public let pathParameters: [String]
    
    /// 路由`path`的对应正则表达式
    private let regExp: NSRegularExpression?
    
    /// 关联的子路由
    public let routes: [FJRoute]
    
    /// 初始化. 注意:`builder`和`interceptor`必须至少提供一项, 否则初始化失败
    /// - Parameters:
    ///   - path: 路由路径: 如果是起始父路由, 其`path`必须以`/`为前缀
    ///   - name: 路由的名称: 如果赋值, 必须提供唯一的字符串名称, 且不能为空
    ///   - builder: 构建路由的`controller`指向
    ///   - displayBuilder: 构建+显示路由的`controller`指向
    ///   - interceptor: 路由拦截器
    ///   - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头
    public init(path: String, name: String? = nil, builder: Builder?, interceptor: (any FJRouteInterceptor)? = nil, routes: [FJRoute] = []) throws {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw CreateError.emptyPath
        }
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let n, n.isEmpty {
            throw CreateError.emptyName
        }
        if builder == nil && interceptor == nil {
            throw CreateError.noPageBuilder
        }
        self.path = p
        self.name = n
        self.builder = builder
        self.interceptor = interceptor
        self.routes = routes
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
    /// 构建路由的`controller`构建器
    public enum Builder: Sendable {
        /// 默认构建方式: 只创建并返回路由的指向`controller`
        ///
        /// 注意不需要在必包内部处理`controller`的显示逻辑
        ///
        /// ```swift
        /// builder: .default({ state in
        ///    let vc = UIViewController()
        ///    return vc
        /// })
        /// ```
        case `default`(_ action: @MainActor @Sendable (_ state: FJRouterState) -> UIViewController)
        
        /// 构建+展示构建方式: 创建, 并且需要在内部处理跳转逻辑并返回路由的指向`controller`。
        /// 要配合路由的`go`或`goNamed`方法进行显示, 不支持手动调用`push`和`present`
        ///
        /// 就算是调用路由的`push`和`present`方法也不会跳转
        ///
        /// 注意一定要在必包内部处理`controller`的显示逻辑: push、present、rootController、自定义转场等等
        ///
        /// ```
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    sourceController.navigationController?.pushViewController(vc, animated: true)
        ///    return vc
        /// })
        ///
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    vc.modalPresentationStyle = .fullScreen
        ///    sourceController.present(vc, animated: true)
        ///    return vc
        /// })
        ///
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    UIApplication.shared.keyWindow?.rootViewController = vc
        ///    return vc
        /// })
        ///
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    vc.modalPresentationStyle = .custom
        ///    vc.transitioningDelegate = xxx
        ///    sourceController.present(vc, animated: true)
        ///    return vc
        /// })
        /// ```
        case display(_ action: @MainActor @Sendable (_ sourceController: UIViewController?, _ state: FJRouterState) -> UIViewController)
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
                return "FJRoute builder or interceptor must be provided"
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
