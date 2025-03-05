import Foundation
import Combine
#if canImport(UIKit)
import UIKit

extension FJRouter {
    /// 路由跳转管理中心
    public static func jump() -> any FJRouterJumpable {
        FJRouter.JumpImpl.shared
    }
}

/// 路由跳转协议
/// 
/// 建议使用goNamed, viewController(name...)方法进行相关操作。
/// 
/// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
/// 
/// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
public protocol FJRouterJumpable: Sendable {
    /// 注册路由
    ///
    /// 注意: 如果注册多个相同的`path`的路由, 后续所有的查找均是指向同一`path`路由中的第一个注册路由
    ///
    ///
    ///     try await FJRouter.jump().registerRoute(FJRoute(path: "/first", name: "first", builder: { _ in FViewController() }, animator: { _ in FJRoute.SystemPushAnimator() }))
    ///
    /// - Parameter route: 路由
    func registerRoute(_ route: FJRoute) async
    
    /// 设置允许重定向的次数
    ///
    ///     await FJRouter.jump().setRedirectLimit(50)
    ///
    /// - Parameter limit: 次数
    func setRedirectLimit(_ limit: UInt) async
    
    /// 设置路由匹配失败时的页面
    ///
    ///     await FJRouter.jump().setErrorBuilder { @MainActor @Sendable state in
    ///         return UIViewController()
    ///     }
    ///
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
    
    /// 通过路由uri(特别是路由名称、路由参数、查询参数)组装路由路径
    ///
    ///     let url = try await FJRouter.jump().convertLocation(by: .name("finda", params: ["id": "1"]))
    ///
    /// 建议在使用路由的时候使用此方法来组装路由路径。
    ///
    /// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
    ///
    /// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
    ///
    /// - Parameters:
    ///   - uri: 路由uri
    /// - Returns: 组装之后的路由路径
    func convertLocation(by uri: FJRouter.URI) async throws(FJRouter.ConvertError) -> String
    
    /// 获取对应的控制器
    ///
    ///     let vc = try await FJRouter.jump().viewController(.loc("/"), extra: nil)
    ///
    /// - Parameters:
    ///   - uri: 路由定位
    ///   - extra: 携带的参数
    /// - Returns: 对应路由控制器
    func viewController(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.JumpMatchError) -> UIViewController
    
    /// 导航至uri对应路由控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - uri: 路由uri
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    ///
    /// 回调使用方法:
    ///
    ///     监听:
    ///     let callback = await FJRouter.jump().go(.name("second"), extra: nil, from: self, ignoreError: true)
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
    ///     触发: 需要viewController方调用
    ///     try? dispatchFJRouterCallBack(name: "haha", value: ())
    ///      dismiss(animated: true, completion: { [weak self] in
    ///         try? self?.dispatchFJRouterCallBack(name: "completion", value: 123)
    ///     })
    @discardableResult
    func go(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async throws(FJRouter.JumpMatchError) -> AnyPublisher<FJRouter.CallbackItem, Never>
}

extension FJRouterJumpable {
    /// 导航至uri对应路由控制器. 外界调用无需使用`await`.
    /// - Parameters:
    ///   - uri: 路由uri
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    ///
    /// 回调使用方法:
    ///
    ///     监听:
    ///     let callback = FJRouter.jump().go(.name("second"))
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
    ///     触发:需要viewController方调用
    ///     try? dispatchFJRouterCallBack(name: "haha", value: ())
    ///      dismiss(animated: true, completion: { [weak self] in
    ///         try? self?.dispatchFJRouterCallBack(name: "completion", value: 123)
    ///     })
    @discardableResult
    public func go(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = true) -> AnyPublisher<FJRouter.CallbackItem, FJRouter.JumpMatchError> {
        return Future<AnyPublisher<FJRouter.CallbackItem, Never>, FJRouter.JumpMatchError>({ promise in
            nonisolated(unsafe) let promise = promise
            Task { @Sendable [weak fromVC] in
                do {
                    let callback = try await self.go(uri, extra: extra, from: fromVC, ignoreError: ignoreError)
                    promise(.success(callback))
                } catch {
                    if let err = error as? FJRouter.JumpMatchError {
                        promise(.failure(err))
                    } else {
                        promise(.failure(FJRouter.JumpMatchError.cancelled))
                    }
                }
            }
        }).flatMap({ obj in
            return obj.setFailureType(to: FJRouter.JumpMatchError.self)
        }).eraseToAnyPublisher()
    }
}
#endif
