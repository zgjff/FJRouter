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
/// 建议使用onReceive(path: "xxx", name: "xxx"), emit(.name(xxx))方法进行相关操作。
///
/// 1: 当事件路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
///  
/// 2: 在实际app中, 事件的`URL`格式可能会随着时间而改变, 但是一般事件名称不会去更改
public protocol FJRouterEventable: Sendable {
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
    
    /// async 通过事件uri触发事件参数
    /// - Parameters:
    ///   - uri: 事件资源标识符
    ///   - extra: 携带的参数
    ///
    ///         无参
    ///         try await FJRouter.event().emit(.name("onSeekSuccess"), extra: nil)
    ///         有参
    ///         try await FJRouter.event().emit(.name("onSeekProgress", params: ["progress": "1"]), extra: nil)
    func emit(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.EmitEventError)
}

extension FJRouterEventable {
    /// 监听事件.无需await: 通过系统`Combine`框架进行响应, 不持有监听者
    ///
    ///     无参
    ///     let seekSuccess = FJRouter.event().onReceive(path: "/seek/success", name: "onSeekSuccess")
    ///     seekSuccess.receive(on: OperationQueue.main)
    ///     .sink(receiveCompletion: { com in
    ///
    ///     }, receiveValue: { info in
    ///         print("onSeekSuccess=>", info)
    ///     }).store(in: &self.cancels)
    ///     
    ///     有参:
    ///      let seekProgress = FJRouter.event().onReceive(path: "/seek/:progress", name: "onSeekProgress")
    ///      seekProgress.receive(on: OperationQueue.main)
    ///      .sink(receiveCompletion: { com in
    ///
    ///      }, receiveValue: { info in
    ///         print("onSeekProgress=>", info)
    ///      }).store(in: &self.cancels)
    ///
    /// - Parameters:
    ///   - path: 事件路径path
    ///   - name: 事件名称
    /// - Returns: 监听事件响应
    public func onReceive(path: String, name: String? = nil) -> AnyPublisher<FJRouter.EventMatchInfo, FJRouterEventAction.CreateError> {
        return Future<AnyPublisher<FJRouter.EventMatchInfo, Never>, FJRouterEventAction.CreateError>({ promise in
            nonisolated(unsafe) let promise = promise
            Task { @Sendable in
                do {
                    let call = try await self.onReceive(path: path, name: name)
                    promise(.success(call))
                } catch {
                    if let err = error as? FJRouterEventAction.CreateError {
                        promise(.failure(err))
                    } else {
                        promise(.failure(.emptyName))
                    }
                }
            }
        }).flatMap({ obj in
            return obj.setFailureType(to: FJRouterEventAction.CreateError.self)
        }).eraseToAnyPublisher()
    }
    
    /// 非 async 通过事件uri触发事件参数
    /// - Parameters:
    ///   - uri: 事件资源标识符
    ///   - extra: 携带的参数
    ///
    ///         无参
    ///         FJRouter.event().emit(.name("onSeekSuccess"), extra: nil)
    ///         有参
    ///         FJRouter.event().emit(.name("onSeekProgress", params: ["progress": "1"]), extra: nil)
    public func emit(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)? = nil) throws(FJRouter.EmitEventError) {
        Task {
            try await self.emit(uri, extra: extra)
        }
    }
}
