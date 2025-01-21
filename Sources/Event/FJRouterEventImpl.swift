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
    func onReceive(path: String, name: String?) async throws -> AnyPublisher<FJRouter.EventMatchInfo, Never> {
        let action = try FJRouterEventAction(path: path, name: nil)
        let listener = await store.saveOrCreateListener(action: action)
        return listener.publisher()
    }

    func emit(_ location: String, extra: (any Sendable)? = nil) throws {
        guard let url = URL(string: location) else {
            return
        }
        try emit(url: url, extra: extra)
    }
    
    func emit(byName name: String, extra: (any Sendable)? = nil) throws {
        
    }
}

private extension FJRouter.EventImpl {
    func emit(url: URL, extra: (any Sendable)? = nil) throws {
        Task { [weak self] in
            guard let self else {
                return
            }
            guard let (listener, info) = await self.store.match(url: url, extra: extra) else {
                return
            }
            listener.receive(value: info)
        }
    }
}
