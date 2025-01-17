import Foundation
import UIKit
import Combine

extension FJRouter {
    /// 路由跳转管理中心
    public static func jump() -> any FJRouterJumpable {
        FJRouter.JumpImpl.shared
    }
}

public protocol FJRouterJumpable {
    /// 注册路由
    ///
    /// 注意: 如果注册多个相同的`path`的路由, 后续所有的查找均是指向同一`path`路由中的第一个注册路由
    ///
    /// - Parameter route: 路由
    func registerRoute(_ route: FJRoute) async
    
    /// 设置允许重定向的次数
    /// - Parameter limit: 次数
    func setRedirectLimit(_ limit: UInt) async
    
    /// 设置路由匹配失败时的页面
    /// - Parameter builder: 失败时的页面创建逻辑
    func setErrorBuilder(_ builder: @escaping (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)) async
    
    /// 是否可以打开url.忽略重定向
    /// - Parameter url: 路由url
    /// - Returns: 结果
    func canOpen(url: URL) async -> Bool
    
    /// 设置获取当前控制器的最上层控制器
    ///
    /// 如果不使用框架提供的`apptopController`,可以提供自己实现的`apptopController`
    func setTopController(action: @escaping @MainActor (_ current: UIViewController?) -> UIViewController?) async
    
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
    func convertLocationBy(name: String, params: [String: String], queryParams: [String: String]) async throws -> String
    
    /// 通过路由路径获取对应的控制器
    ///
    /// 1: 如果匹配路由成功, 且路由的`builder`不为nil, 则返回`builder`内部创建的控制器
    ///
    /// 2: 如果匹配路由成功, 且路由的`builder`为nil, 则返回`nil`
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    /// - Returns: 控制器
    func viewController(forLocation location: String, extra: (any Sendable)?) async throws -> UIViewController
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 查询参数
    ///   - extra: 携带的参数
    /// - Returns: 控制器
    func viewController(forName name: String, params: [String: String], queryParams: [String: String], extra: (any Sendable)?) async throws -> UIViewController
    
    /// 导航至对应路由路径控制器
    ///
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    func go(location: String, extra: (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) throws
    
    /// 导航至对应路由名称控制器
    ///
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    func goNamed(_ name: String, params: [String: String], queryParams: [String: String], extra: (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) throws
    
    /// 导航至对应路由路径控制器: 此方法支持通过`Combine`框架进行路由回调
    ///
    /// 回调使用方法:
    ///
    ///     监听:
    ///     let callback = await FJRouter.shared.go(location: "/second")
    ///     callback.sink(receiveCompletion: { cop in
    ///         print("cop----全部", cop)
    ///     }, receiveValue: { item in
    ///         print("value----全部", item)
    ///     }).store(in: &cancels)
    ///
    ///     callback.filter({ $0.name == "completion" })
    ///     .sink(receiveCompletion: { cop in
    ///         print("cop----特殊:", cop)
    ///     }, receiveValue: { item in
    ///         print("value----特殊:", item)
    ///     }).store(in: &cancels)
    ///
    ///     触发:
    ///     try? dispatchFJRouterCallBack(name: "haha", value: ())
    ///      dismiss(animated: true, completion: { [weak self] in
    ///         try? self?.dispatchFJRouterCallBack(name: "completion", value: 123)
    ///     })
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    func go(location: String, extra: (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError>
    
    /// 导航至对应路由名称控制器: 此方法支持通过`Combine`框架进行路由回调
    ///
    /// 回调使用方法:
    ///
    ///     监听:
    ///     let callback = await FJRouter.shared.goNamed("second")
    ///     callback.sink(receiveCompletion: { cop in
    ///         print("cop----全部", cop)
    ///     }, receiveValue: { item in
    ///         print("value----全部", item)
    ///     }).store(in: &cancels)
    ///
    ///     callback.filter({ $0.name == "completion" })
    ///     .sink(receiveCompletion: { cop in
    ///         print("cop----特殊:", cop)
    ///     }, receiveValue: { item in
    ///         print("value----特殊:", item)
    ///     }).store(in: &cancels)
    ///
    ///     触发:
    ///     try? dispatchFJRouterCallBack(name: "haha", value: ())
    ///      dismiss(animated: true, completion: { [weak self] in
    ///         try? self?.dispatchFJRouterCallBack(name: "completion", value: 123)
    ///     })
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    func goNamed(_ name: String, params: [String: String], queryParams: [String: String], extra: (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError>
}
