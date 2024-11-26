//
//  FJRoute.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import UIKit

public struct FJRoute: Sendable {
    /// 构建路由的`controller`
    public typealias PageBuilder = (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)
    
    /// 构建路由的显示逻辑: 当未设置window的`rootController`的时候`sourceController`为nil
    public typealias DisplayBuilder = (@MainActor @Sendable (_ sourceController: UIViewController?, _ state: FJRouterState) -> UIViewController)
    
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
    
    /// 构建路由的`controller`指向
    public let builder: PageBuilder?
    
    /// 构建+显示路由的`controller`指向.eg:
    ///
    /// ```
    /// displayBuilder: { sourceController, state in
    ///    let vc = UIViewController()
    ///    sourceController.navigationController?.pushViewController(vc, animated: true)
    ///    return vc
    /// }
    ///
    /// displayBuilder: { sourceController, state in
    ///    let vc = UIViewController()
    ///    vc.modalPresentationStyle = .fullScreen
    ///    sourceController.present(vc, animated: true)
    ///    return vc
    /// }
    ///
    /// displayBuilder: { sourceController, state in
    ///    let vc = UIViewController()
    ///    UIApplication.shared.keyWindow?.rootViewController = vc
    ///    return vc
    /// }
    ///
    /// displayBuilder: { sourceController, state in
    ///    let vc = UIViewController()
    ///    vc.modalPresentationStyle = .custom
    ///    vc.transitioningDelegate = xxx
    ///    sourceController.present(vc, animated: true)
    ///    return vc
    /// }
    /// ```
    public let displayBuilder: DisplayBuilder?
    
    /// 路由拦截器
    public let interceptor: (any FJRouteInterceptor)?
    
    /// 路由`path`中的参数名称
    public let pathParameters: [String]
    
    /// 路由`path`的对应正则表达式
    private let regExp: NSRegularExpression?
    
    /// 关联的子路由
    public let routes: [FJRoute]
    
    /// 初始化。注意:
    ///
    /// 1: `builder`、`displayBuilder`和`interceptor`必须至少提供一项, 否则初始化失败
    ///
    /// 2: `builder`和`displayBuilder`都是提供创建路由控制器的构建, 但是`builder`一般是只提供创建, 而`displayBuilder`则
    /// 必须需要额外提供显示对应控制器的方法
    ///
    /// 3: 因为`displayBuilder`方法需要额外提供显示对应控制器的方法, 要配合路由的`go`或`goNamed`方法进行显示,
    /// 不支持手动调用`push`和`present`
    ///
    /// 4: `builder`和`displayBuilder`只需提供一个即可, 但是若要两者都提供, 则以`displayBuilder`方法为主; 如果提供了`displayBuilder`则必须使用`go`以及`goNamed`方法进行显示
    ///
    /// - Parameters:
    ///   - path: 路由路径: 如果是起始父路由, 其`path`必须以`/`为前缀
    ///   - name: 路由的名称: 如果赋值, 必须提供唯一的字符串名称, 且不能为空
    ///   - builder: 构建路由的`controller`指向
    ///   - displayBuilder: 构建+显示路由的`controller`指向
    ///   - interceptor: 路由拦截器
    ///   - routes: 关联的子路由: 强烈建议子路由的`path`不要以`/`为开头
    public init(path: String, name: String? = nil, builder: PageBuilder?, displayBuilder: DisplayBuilder? = nil, interceptor: (any FJRouteInterceptor)? = nil, routes: [FJRoute] = []) throws {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw CreateError.emptyPath
        }
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let n, n.isEmpty {
            throw CreateError.emptyName
        }
        if builder == nil && interceptor == nil && displayBuilder == nil {
            throw CreateError.noPageBuilder
        }
        self.path = p
        self.name = n
        self.builder = builder
        self.interceptor = interceptor
        self.displayBuilder = displayBuilder
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
    public enum CreateError: Error, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
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
                return "FJRoute builder or guards must be provided"
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
