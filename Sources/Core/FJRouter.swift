// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

/// 路由管理中心
final public class FJRouter: Sendable {
    public static let shared = FJRouter()
    fileprivate let store: FJRouterStore
    fileprivate let core: FJRouterCore
    private init() {
        store = FJRouterStore()
        core = FJRouterCore()
    }
}

// MARK: - set
extension FJRouter {
    /// 注册路由
    ///
    /// 如果已经存在路由, 则会替换旧路由信息。简单通过路由`path`判断两个路由是否相同
    ///
    /// - Parameter route: 路由
    public func registerRoute(_ route: FJRoute) async {
        await store.addRoute(route)
    }
    
    /// 注册路由
    ///
    /// 如果已经存在路由, 则会替换旧路由信息。简单通过路由`path`判断两个路由是否相同
    ///
    /// - Parameter route: 路由
    public func registerRoute(_ route: FJRoute) {
        Task {
            await registerRoute(route)
        }
    }
    
    /// 通过path注册路由
    ///
    /// 注意:`builder`、`displayBuilder`和`interceptor`必须至少提供一项, 否则注册失败。如果提供了`displayBuilder`则必须使用`go`以及`goNamed`方法进行显示
    ///
    /// 如果已经存在路由, 则会替换旧路由信息。简单通过路由`path`判断两个路由是否相同
    ///
    /// displayBuilder一般用于匹配成功之后, 非自己调用`push`,`present`等自主操作行为。用于`go(location: String......)`方法
    ///
    /// - Parameters:
    ///   - path: 要注册的路由path
    ///   - name: 路由名称
    ///   - builder: 构建路由的`controller`指向
    ///   - displayBuilder: 构建+显示路由的`controller`指向。一般用于匹配成功之后,
    ///     非自己调用`push`,`present`等自主操作行为。用于`go(location: String......)`方法
    ///   - interceptor: 路由拦截器: 注意协议中`redirectRoute`方法不能返回空
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
    public func registerRoute(path: String, name: String? = nil, builder: FJRoute.PageBuilder?, displayBuilder: FJRoute.DisplayBuilder? = nil, interceptor: (any FJRouteInterceptor)? = nil) async throws {
        let route = try FJRoute(path: path, name: name, builder: builder, displayBuilder: displayBuilder, interceptor: interceptor)
        await store.addRoute(route)
    }
    
    /// 通过path注册路由
    ///
    /// 注意:`builder`、`displayBuilder`和`interceptor`, 否则注册失败。如果提供了`displayBuilder`则必须使用`go`以及`goNamed`方法进行显示
    ///
    /// 如果已经存在路由, 则会替换旧路由信息。简单通过路由`path`判断两个路由是否相同
    ///
    /// - Parameters:
    ///   - path: 要注册的路由path
    ///   - name: 路由名称
    ///   - builder: 构建路由的`controller`指向
    ///   - displayBuilder: 构建+显示路由的`controller`指向。一般用于匹配成功之后,
    ///    非自己调用`push`,`present`等自主操作行为。用于`go(location: String......)`方法
    ///
    ///   - interceptor: 路由拦截器: 注意协议中`redirectRoute`方法不能返回空
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
    public func registerRoute(path: String, name: String? = nil, builder: FJRoute.PageBuilder?, displayBuilder: FJRoute.DisplayBuilder? = nil, interceptor: (any FJRouteInterceptor)? = nil) throws {
        let route = try FJRoute(path: path, name: name, builder: builder, displayBuilder: displayBuilder, interceptor: interceptor)
        Task {
            await store.addRoute(route)
        }
    }
    
    /// 通过路由名称、路由参数、查询参数组装路由路径
    ///
    /// 建议在使用路由的时候使用此方法来组装路由路径。
    ///
    /// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
    ///
    /// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
    ///
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    /// - Returns: 组装之后的路由路径
    public func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) async -> String? {
        await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
    }
    
    /// 通过路由名称、路由参数、查询参数组装路由路径. 强烈建议在使用路由的时候使用此方法来组装路由路径。
    ///
    /// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
    ///
    /// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
    ///
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - completion: 回调
    public func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:], completion: @Sendable @escaping (_ location: String?) -> ()) {
        Task {
            let loc = await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
            completion(loc)
        }
    }
    
    /// 设置允许重定向的次数
    /// - Parameter limit: 次数
    public func setRedirectLimit(_ limit: UInt) {
        Task {
            await store.setRedirectLimit(limit)
        }
    }
    
    /// 设置路由匹配失败时的页面
    /// - Parameter builder: 失败时的页面创建逻辑
    public func setErrorBuilder(_ builder: @escaping FJRoute.PageBuilder) {
        core.errorBuilder = builder
    }
    
    /// 设置获取当前控制器的最上层控制器
    ///
    /// 如果不使用框架提供的`apptopController`,可以提供自己实现的`apptopController`
    public func setTopController(action: @escaping @MainActor (_ current: UIViewController?) -> UIViewController?) {
        core.apptopController = action
    }
}

// MARK: - core
extension FJRouter {
    /// 通过路由路径获取对应的控制器
    ///
    /// 1: 如果匹配路由成功, 且路由的`builder`不为nil, 则返回`builder`内部创建的控制器
    ///
    /// 2: 如果匹配路由成功, 且路由的`builder`为nil, 则返回`nil`
    ///
    /// 3: 如果路由匹配失败, 且`ignoreError`为`false`, 则会返回`errorBuilder`返回的控制器
    ///
    /// 4: 如果路由匹配失败, 且`ignoreError`为`true`, 则会返回`nil`
    ///
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    /// - Returns: 控制器
    public func viewController(forLocation location: String, extra: (any Sendable)? = nil, ignoreError: Bool = false) async -> UIViewController? {
        guard let url = URL(string: location) else {
            return nil
        }
        let match = await store.match(url: url, extra: extra)
        return await core.viewController(for: match, ignoreError: ignoreError)
    }
    
    /// 通过路由路径获取对应的控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    ///   - completion: 回调获取的控制器
    public func viewController(forLocation location: String, extra: (any Sendable)? = nil, ignoreError: Bool = false, completion: @Sendable @escaping (_ controller: UIViewController) -> ()) {
        guard let url = URL(string: location) else {
            return
        }
        Task {
            let match = await store.match(url: url, extra: extra)
            if let viewController = await core.viewController(for: match, ignoreError: ignoreError) {
                completion(viewController)
            }
        }
    }
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 查询参数
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    /// - Returns: 控制器
    public func viewController(forName name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, ignoreError: Bool = false) async -> UIViewController? {
        guard let loc = await convertLocationBy(name: name, params: params, queryParams: queryParams) else {
            return nil
        }
        return await viewController(forLocation: loc, extra: extra, ignoreError: ignoreError)
    }
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 查询参数
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    ///   - completion: 回调
    public func viewController(forName name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, ignoreError: Bool = false, completion: @Sendable @escaping (_ controller: UIViewController) -> ()) {
        Task {
            if let viewController = await viewController(forName: name, params: params, queryParams: queryParams, extra: extra) {
                completion(viewController)
            }
        }
    }
    
    /// 导航至对应路由路径控制器。
    ///
    /// 会优先调用路由的`displayBuilder`方法; 若是`displayBuilder`为`nil`, 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func go(location: String, extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) async {
        guard let url = URL(string: location) else {
            return
        }
        let match = await store.match(url: url, extra: extra)
        await core.go(matchList: match, sourceController: sourceController, ignoreError: ignoreError, animated: true)
    }
    
    /// 导航至对应路由路径控制器
    ///
    /// 会优先调用路由的`displayBuilder`方法; 若是`displayBuilder`为`nil`, 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func go(location: String, extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) {
        Task {
            await go(location: location, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// 导航至对应路由名称控制器
    ///
    /// 会优先调用路由的`displayBuilder`方法; 若是`displayBuilder`为`nil`, 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func goNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) async {
        guard let loc = await convertLocationBy(name: name, params: params, queryParams: queryParams) else {
            return
        }
        await go(location: loc, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
    }
    
    /// 导航至对应路由名称控制器
    ///
    /// 会优先调用路由的`displayBuilder`方法; 若是`displayBuilder`为`nil`, 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func goNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) {
        Task {
            await goNamed(name, params: params, queryParams: queryParams, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// push到对应路由路径控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func push(location: String, extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) async {
        guard let url = URL(string: location) else {
            return
        }
        let match = await store.match(url: url, extra: extra)
        await core.push(matchList: match, sourceController: sourceController, ignoreError: ignoreError, animated: true)
    }
    
    /// push到对应路由路径控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func push(location: String, extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) {
        Task {
            await push(location: location, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// push至对应路由名称控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    ///   - extra: 携带的参数
    public func pushNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) async {
        guard let loc = await convertLocationBy(name: name, params: params, queryParams: queryParams) else {
            return
        }
        await push(location: loc, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
    }
    
    /// push至对应路由名称控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    ///   - extra: 携带的参数
    public func pushNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) {
        Task {
            await pushNamed(name, params: params, queryParams: queryParams, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// present到对应路由路径控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func present(location: String, extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) async {
        guard let url = URL(string: location) else {
            return
        }
        let match = await store.match(url: url, extra: extra)
        await core.present(matchList: match, sourceController: sourceController, ignoreError: ignoreError, animated: true)
    }
    
    /// present到对应路由路径控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func present(location: String, extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) {
        Task {
            await present(location: location, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// present至对应路由名称控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func presentNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) async {
        guard let loc = await convertLocationBy(name: name, params: params, queryParams: queryParams) else {
            return
        }
        await present(location: loc, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
    }
    
    /// present至对应路由名称控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器
    public func presentNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, sourceController: UIViewController? = nil, ignoreError: Bool = false) {
        Task {
            await presentNamed(name, params: params, queryParams: queryParams, extra: extra, sourceController: sourceController, ignoreError: ignoreError)
        }
    }
}
