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

    func emit(_ location: String, extra: (any Sendable)? = nil) async throws {
        guard let url = URL(string: location) else {
            return
        }
        guard let (listener, info) = await store.match(url: url, extra: extra) else {
            return
        }
        listener.receive(value: info)
    }
    
    func emit(byName name: String, params: [String : String], queryParams: [String : String], extra: (any Sendable)?) async throws {
        let loc =  try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
        try await emit(loc, extra: extra)
    }
}
