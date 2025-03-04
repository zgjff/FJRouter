//
//  FJRouter+Jump+DefaultParameters.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/18.
//

import Foundation
import Combine
#if canImport(UIKit)
import UIKit
extension FJRouterJumpable {
    /// 通过路由名称参数获取对应的控制器
    ///
    ///     let vc = try await FJRouter.jump().viewController(byName: FJRouter.FindControllerByNameParams.init(name: "second"))
    ///
    /// - Parameter params: 查询参数
    public func viewController(byName params: FJRouter.FindControllerByNameParams) async throws(FJRouter.JumpMatchError) -> UIViewController {
        try await viewController(byName: params.name, params: params.params, queryParams: params.queryParams, extra: params.extra)
    }
    
    /// 通过路由路径参数导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameter params: 参数
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    ///
    /// 回调使用方法:
    ///
    ///     监听:
    ///     let callback = await FJRouter.jump().go(location: FJRouter.GoByLocationParams.init(location: "/second"))
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
    public func go(location params: FJRouter.GoByLocationParams) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.JumpMatchError> {
        return await go(location: params.location, extra: params.extra, from: params.fromVC, ignoreError: params.ignoreError)
    }
    
    /// 通过路由名称参数导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameter params: 参数
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    ///
    /// 回调使用方法:
    ///
    ///     监听:
    ///     let callback = await FJRouter.jump().goNamed(FJRouter.GoByNameParams.init(name: "second"))
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
    public func goNamed(_ params: FJRouter.GoByNameParams) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.JumpMatchError> {
        return await goNamed(params.name, params: params.params, queryParams: params.queryParams, extra: params.extra, from: params.fromVC, ignoreError: params.ignoreError)
    }
}

extension FJRouter {
    /// 通过路由名称查询对应控制器: 方便协议方法传递默认参数
    public struct FindControllerByNameParams: Sendable {
        fileprivate let name: String
        fileprivate let params: [String : String]
        fileprivate let queryParams: [String : String]
        fileprivate let extra: @Sendable () -> (any Sendable)
        
        /// 初始化
        /// - Parameters:
        ///   - name: 路由名称
        ///   - params: 路由参数
        ///   - queryParams: 路由查询参数
        ///   - extra: 携带的参数
        public init(name: String, params: [String : String] = [:], queryParams: [String : String] = [:], extra: @autoclosure @escaping @Sendable () -> (any Sendable)? = nil) {
            self.name = name
            self.params = params
            self.queryParams = queryParams
            self.extra = extra
        }
    }
    
    /// 通过路由路径导航参数: 方便协议方法传递默认参数
    public struct GoByLocationParams: Sendable {
        fileprivate let location: String
        fileprivate let fromVC: UIViewController?
        fileprivate let ignoreError: Bool
        fileprivate let extra: @Sendable () -> (any Sendable)
        
        /// 初始化
        /// - Parameters:
        ///   - location: 路由路径
        ///   - extra: 携带的参数
        ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
        ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
        public init(location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = true) {
            self.location = location
            self.fromVC = fromVC
            self.ignoreError = ignoreError
            self.extra = extra
        }
    }
    
    /// 通过路由名称导航参数: 方便协议方法传递默认参数
    public struct GoByNameParams: Sendable {
        fileprivate let name: String
        fileprivate let params: [String : String]
        fileprivate let queryParams: [String : String]
        fileprivate let fromVC: UIViewController?
        fileprivate let ignoreError: Bool
        fileprivate let extra: @Sendable () -> (any Sendable)
        
        /// 初始化
        ///   - name: 路由名称
        ///   - params: 路由参数
        ///   - queryParams: 路由查询参数
        ///   - extra: 携带的参数
        ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
        ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
        public init(name: String, params: [String : String] = [:], queryParams: [String : String] = [:], extra: @autoclosure @escaping @Sendable () -> (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = true) {
            self.name = name
            self.params = params
            self.queryParams = queryParams
            self.fromVC = fromVC
            self.ignoreError = ignoreError
            self.extra = extra
        }
    }
}

#endif
