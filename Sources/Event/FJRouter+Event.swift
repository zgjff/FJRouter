//
//  FJRouter+Event.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import Combine

extension FJRouter {
    /// 事件总线管理中心
    public static func event() -> any FJRouterEventable {
        FJRouter.EventImpl.shared
    }
}

/// 事件总线协议
///
/// 建议使用onReceive(path: "xxx", name: "xxx"), emit(name: xxx)方法进行相关操作。
///
/// 1: 当事件路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
///
/// 2: 在实际app中, 事件的`URL`格式可能会随着时间而改变, 但是一般事件名称不会去更改
public protocol FJRouterEventable {
    /// 监听事件: 通过系统`Combine`框架进行响应, 不持有监听者
    ///
    ///     无参
    ///     let seekSuccess = try await FJRouter.event().onReceive(path: "/seek/success", name: "onSeekSuccess")
    ///     seekSuccess.receive(on: OperationQueue.main)
    ///     .sink(receiveValue: { info in
    ///         print("onSeekSuccess=>", info)
    ///     }).store(in: &self.cancels)
    ///
    ///     有参
    ///     let seekProgress = try await FJRouter.event().onReceive(path: "/seek/:progress", name: "onSeekProgress")
    ///     seekProgress.receive(on: OperationQueue.main)
    ///     .sink(receiveValue: { info in
    ///         print("onSeekProgress=>", info)
    ///     }).store(in: &self.cancels)
    ///
    /// - Parameters:
    ///   - path: 事件路径path
    ///   - name: 事件名称
    /// - Returns: 监听事件响应
    func onReceive(path: String, name: String?) async throws(FJRouterEventAction.CreateError) -> AnyPublisher<FJRouter.EventMatchInfo, Never>
    
    /// 通过事件url路径触发事件: 通过系统`Combine`框架进行响应, 不持有监听者
    /// - Parameters:
    ///   - location: 路径.
    ///   - extra: 携带的参数
    ///
    ///         无参
    ///         try await FJRouter.event().emit("/seek/success", extra: 5)
    ///         有参: 1就是监听"/seek/:progress"中的progress字段
    ///         try await FJRouter.event().emit("/seek/1", extra: nil)
    ///
    func emit(_ location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.EmitEventError)
    
    /// async 通过事件名称触发事件参数: 通过系统`Combine`框架进行响应, 不持有监听者
    /// - Parameters:
    ///   - name: 事件名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    ///
    ///         无参
    ///         try await FJRouter.event().emit(name: "onSeekSuccess", params: [:], queryParams: [:], extra: 5)
    ///         有参
    ///         try await FJRouter.event().emit(name: "onSeekProgress", params: ["progress": "1"], queryParams: [:], extra: nil)
    ///
    func emit(name: String, params: [String : String], queryParams: [String : String], extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.EmitEventError)
}

extension FJRouterEventable {
    /// 监听事件
    ///
    ///     无参
    ///     try await FJRouter.event().emit("/seek/success", extra: 5)
    ///     有参: 1就是监听"/seek/:progress"中的progress字段
    ///      try await FJRouter.event().emit("/seek/1", extra: nil)
    ///
    /// - Parameter path: 事件路径path
    ///   - name: 事件名称
    public func onReceive(path: String) async throws(FJRouterEventAction.CreateError) -> AnyPublisher<FJRouter.EventMatchInfo, Never> {
        try await onReceive(path: path, name: nil)
    }
    
    /// 通过事件名称触发事件
    /// - Parameter params: 参数
    ///
    ///     无参
    ///     try await FJRouter.event().emit(name: FJRouter.EmitEventByNameParams.init(name: "onSeekSuccess"))
    ///     有参: 1就是监听"/seek/:progress"中的progress字段
    ///      try await FJRouter.event().emit(name: FJRouter.EmitEventByNameParams.init(name: "onSeekProgress", params: ["progress": "1"]))
    ///
    public func emit(name params: FJRouter.EmitEventByNameParams) async throws(FJRouter.EmitEventError) {
        try await emit(name: params.name, params: params.params, queryParams: params.queryParams, extra: params.extra)
    }
}

extension FJRouter {
    /// 通过事件名称触发事件参数: 方便协议方法传递默认参数
    public struct EmitEventByNameParams: Sendable {
        fileprivate let name: String
        fileprivate let params: [String : String]
        fileprivate let queryParams: [String : String]
        fileprivate let extra: @Sendable () -> (any Sendable)?
        
        /// 初始化
        /// - Parameters:
        ///   - name: 事件名称
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
}
