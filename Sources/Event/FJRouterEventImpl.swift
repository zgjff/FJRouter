//
//  FJRouterEventImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import Combine

extension FJRouter {
    /// 事件总线
    final class EventImpl: Sendable {
        internal static let shared = EventImpl()
        private let store: EventStore
        private init() {
            store = EventStore()
        }
    }
}

extension FJRouter.EventImpl: FJRouterEventable {
    /// 监听
    func onReceive(action: FJRouterEventAction) async -> AnyPublisher<Void, Never> {
        let listener = await store.saveOrCreateListener(action: action)
        return listener.publisher()
    }
    
    /// 监听
    func onReceive(path: String) async throws -> AnyPublisher<Void, Never> {
        let action = try FJRouterEventAction(path: path, name: nil)
        return await onReceive(action: action)
    }
    
    /// 触发
    func emit(location: String, extra: (any Sendable)? = nil) {
        
    }
    
    func emit(name: String, extra: (any Sendable)? = nil) {
        
    }
}
