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
        let action = try FJRouterEventAction(path: path, name: name)
        let listener = await store.saveOrCreateListener(action: action)
        return listener.publisher()
    }

    func emit(_ location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) throws {
        guard let url = URL(string: location) else {
            return
        }
        Task {
            guard let (listener, info) = await self.store.match(url: url, extra: extra()) else {
                return
            }
            listener.receive(value: info)
        }
    }
    
    func emit(byName parameters: FJRouter.EmitEventByName) throws {
        try emit(byName: parameters.name, params: parameters.params, queryParams: parameters.queryParams, extra: parameters.extra)
    }
    
    func emit(byName name: String, params: [String : String], queryParams: [String : String], extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) throws {
        Task {
            let loc =  try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
            try self.emit(loc, extra: extra)
        }
    }
}
