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
    /// 注意: 如果注册多个相同的`path`的路由, 后续所有的查找均是指向同一`path`路由中的第一个注册路由
    ///
    /// - Parameter route: 路由
    public func registerRoute(_ route: FJRoute) async {
        await store.addRoute(route)
    }
    
    /// 通过path注册路由
    ///
    /// 注意:`builder`和`redirect`必须至少提供一项, 否则注册失败。
    ///
    /// 注意: 如果注册多个相同的`path`的路由, 后续所有的查找均是指向同一`path`路由中的第一个注册路由
    ///
    /// - Parameters:
    ///   - path: 要注册的路由path
    ///   - name: 路由名称
    ///   - builder: 构建路由的`controller`方式
    ///     非自己调用`push`,`present`等自主操作行为。用于`go(location: String......)`方法
    ///   - redirect: 路由重定向
    public func registerRoute(path: String, name: String? = nil, builder: FJRoute.Builder?, redirect: (any FJRouteRedirector)? = nil) async throws {
        let route = try FJRoute(path: path, name: name, builder: builder, redirect: redirect)
        await store.addRoute(route)
    }
    
    /// 通过路由名称、路由参数、查询参数组装路由路径
    ///
    /// 建议在使用路由的时候使用此方法来组装路由路径。
    ///
    /// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
    ///
    /// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    /// - Returns: 组装之后的路由路径
    public func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) async throws -> String {
        try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
    }
    
    /// 设置允许重定向的次数
    /// - Parameter limit: 次数
    public func setRedirectLimit(_ limit: UInt) async {
        await store.setRedirectLimit(limit)
    }
    
    /// 设置路由匹配失败时的页面
    /// - Parameter builder: 失败时的页面创建逻辑
    public func setErrorBuilder(_ builder: @escaping (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)) async {
        await withCheckedContinuation { continuation in
            self.core.errorBuilder = builder
            continuation.resume()
        }
    }
    
    /// 设置获取当前控制器的最上层控制器
    ///
    /// 如果不使用框架提供的`apptopController`,可以提供自己实现的`apptopController`
    public func setTopController(action: @escaping @MainActor (_ current: UIViewController?) -> UIViewController?) async {
        await withCheckedContinuation { continuation in
            self.core.apptopController = action
            continuation.resume()
        }
    }
}

// MARK: - core
extension FJRouter {
    /// 通过路由路径获取对应的控制器
    ///
    /// 1: 如果匹配路由成功, 且路由的`builder`不为nil, 则返回`builder`内部创建的控制器
    ///
    /// 2: 如果匹配路由成功, 且路由的`builder`为nil, 则返回`nil`
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    /// - Returns: 控制器
    public func viewController(forLocation location: String, extra: (any Sendable)? = nil) async throws -> UIViewController {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: true)
        if let destvc = await core.viewController(for: match) {
            return destvc
        }
        throw FJRouter.MatchError.noBuilder
    }
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 查询参数
    ///   - extra: 携带的参数
    /// - Returns: 控制器
    public func viewController(forName name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil) async throws -> UIViewController {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            let destvc = try await viewController(forLocation: loc, extra: extra)
            return destvc
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
    
    /// 导航至对应路由路径控制器。
    ///
    /// 若路由的`builder`为`default`: 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func go(location: String, extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) async throws {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: ignoreError)
        await core.go(matchList: match, sourceController: sourceController, ignoreError: ignoreError, animated: true)
    }
    
    /// 导航至对应路由路径控制器
    ///
    /// 若路由的`builder`为`default`: 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func go(location: String, extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await go(location: location, extra: extra, from: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// 导航至对应路由名称控制器
    ///
    /// 若路由的`builder`为`default`: 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func goNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) async throws {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            try await go(location: loc, extra: extra, from: sourceController, ignoreError: ignoreError)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
    
    /// 导航至对应路由名称控制器
    ///
    /// 若路由的`builder`为`default`: 框架内部会先尝试`push`, 然后尝试`present`
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func goNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await goNamed(name, params: params, queryParams: queryParams, extra: extra, from: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// `push`到对应路由路径控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`push`
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func push(location: String, extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) async throws {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: ignoreError)
        await core.push(matchList: match, sourceController: sourceController, ignoreError: ignoreError, animated: true)
    }
    
    /// `push`到对应路由路径控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`push`
    /// - Parameters:
    ///   - location: 路由路径
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func push(location: String, extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await push(location: location, extra: extra, from: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// `push`至对应路由名称控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`push`
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    ///   - extra: 携带的参数
    public func pushNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) async throws {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            try await push(location: loc, extra: extra, from: sourceController, ignoreError: ignoreError)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
    
    /// `push`至对应路由名称控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`push`
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    ///   - extra: 携带的参数
    public func pushNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await pushNamed(name, params: params, queryParams: queryParams, extra: extra, from: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// `present`到对应路由路径控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`present`
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func present(location: String, extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) async throws {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: ignoreError)
        await core.present(matchList: match, sourceController: sourceController, ignoreError: ignoreError, animated: true)
    }
    
    /// present到对应路由路径控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`present`
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func present(location: String, extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await present(location: location, extra: extra, from: sourceController, ignoreError: ignoreError)
        }
    }
    
    /// present至对应路由名称控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`present`
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func presentNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) async throws {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            try await present(location: loc, extra: extra, from: sourceController, ignoreError: ignoreError)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
    
    /// present至对应路由名称控制器
    ///
    /// 若路由的`builder`为`display`: 框架只会调用`block`内部显示逻辑, 不会`present`
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - sourceController: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    public func presentNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from sourceController: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await presentNamed(name, params: params, queryParams: queryParams, extra: extra, from: sourceController, ignoreError: ignoreError)
        }
    }
}
