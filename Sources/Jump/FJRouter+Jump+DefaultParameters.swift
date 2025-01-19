//
//  FJRouter+Jump+DefaultParameters.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/18.
//

import Foundation
import UIKit
import Combine

// MARK: - get
extension FJRouterJumpable {
    /// 通过路由路径获取对应的控制器
    /// - Parameters:
    ///   - location: 路由路径
    /// - Returns: 对应路由控制器
    public func viewController(byLocation location: String) async throws -> UIViewController {
        try await viewController(byLocation: location, extra: nil)
    }
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    /// - Returns: 对应路由控制器
    public func viewController(byName name: String) async throws -> UIViewController {
        try await viewController(byName: name, params: [:], queryParams: [:], extra: nil)
    }
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    /// - Returns: 对应路由控制器
    public func viewController(byName name: String, params: [String : String]) async throws -> UIViewController {
        try await viewController(byName: name, params: params, queryParams: [:], extra: nil)
    }
    
    /// 通过路由名称获取对应的控制器
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    /// - Returns: 对应路由控制器
    public func viewController(byName name: String, params: [String : String], queryParams: [String : String]) async throws -> UIViewController {
        try await viewController(byName: name, params: params, queryParams: queryParams, extra: nil)
    }
}

// MARK: - go
extension FJRouterJumpable {
    /// 通过路由路径导航至对应控制器
    /// - Parameters:
    ///   - location: 路由路径
    public func go(_ location: String) throws {
        try go(location, extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由路径导航至对应控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    public func go(_ location: String, extra: (any Sendable)?) throws {
        try go(location, extra: extra, from: nil, ignoreError: false)
    }
    
    /// 通过路由路径导航至对应控制器
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    public func go(_ location: String, extra: (any Sendable)?, from fromVC: UIViewController?) throws {
        try go(location, extra: extra, from: fromVC, ignoreError: false)
    }
    
    /// 通过路由路径导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - location: 路由路径
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func go(_ location: String) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        return await go(location, extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由路径导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func go(_ location: String, extra: (any Sendable)?) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        return await go(location, extra: extra, from: nil, ignoreError: false)
    }
    
    /// 通过路由路径导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - location: 路由路径
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func go(_ location: String, extra: (any Sendable)?, from fromVC: UIViewController?) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        return await go(location, extra: extra, from: fromVC, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器
    ///   - name: 路由名称
    public func goNamed(_ name: String) throws {
        try goNamed(name, params: [:], queryParams: [:], extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器
    ///   - name: 路由名称
    ///   - params: 路由参数
    public func goNamed(_ name: String, params: [String : String]) throws {
        try goNamed(name, params: params, queryParams: [:], extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    public func goNamed(_ name: String, params: [String : String], queryParams: [String : String]) throws {
        try goNamed(name, params: params, queryParams: queryParams, extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    public func goNamed(_ name: String, params: [String : String], queryParams: [String : String], extra: (any Sendable)?) throws {
        try goNamed(name, params: params, queryParams: queryParams, extra: extra, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    public func goNamed(_ name: String, params: [String : String], queryParams: [String : String], extra: (any Sendable)?, from fromVC: UIViewController?) throws {
        try goNamed(name, params: params, queryParams: queryParams, extra: extra, from: fromVC, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - name: 路由名称
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func goNamed(_ name: String) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        await goNamed(name, params: [:], queryParams: [:], extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func goNamed(_ name: String, params: [String : String]) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        await goNamed(name, params: params, queryParams: [:], extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func goNamed(_ name: String, params: [String : String], queryParams: [String : String]) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        await goNamed(name, params: params, queryParams: queryParams, extra: nil, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func goNamed(_ name: String, params: [String : String], queryParams: [String : String], extra: (any Sendable)?) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        await goNamed(name, params: params, queryParams: queryParams, extra: extra, from: nil, ignoreError: false)
    }
    
    /// 通过路由名称导航至对应控制器: 此方法支持通过`Combine`框架进行路由回调
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
    /// - Returns: 路由回调.⚠️⚠️⚠️不要持有此对象, 防止内存泄漏⚠️⚠️⚠️
    @discardableResult
    public func goNamed(_ name: String, params: [String : String], queryParams: [String : String], extra: (any Sendable)?, from fromVC: UIViewController?) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        await goNamed(name, params: params, queryParams: queryParams, extra: extra, from: fromVC, ignoreError: false)
    }
}
