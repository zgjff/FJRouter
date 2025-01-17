//
//  FJRouter+Event.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import Combine

extension FJRouter {
    /// 事件总线
    public static func event() -> any FJRouterEventable {
        FJRouter.EventImpl.shared
    }
}

/// 事件总线协议
public protocol FJRouterEventable {
    /// 监听
    func onReceive(action: FJRouterEventAction) async -> AnyPublisher<Void, Never>
    
    /// 监听
    func onReceive(path: String) async throws -> AnyPublisher<Void, Never>
    
    /// 触发
    func emit(location: String, extra: (any Sendable)?)
    
    func emit(name: String, extra: (any Sendable)?)
}
