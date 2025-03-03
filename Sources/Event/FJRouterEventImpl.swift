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
    internal final class EventImpl: FJRouterEventable, Sendable {
        internal static let shared = EventImpl()
        private let store: EventStore
        private init() {
            store = EventStore()
        }
    }
}

extension FJRouter.EventImpl {
    func onReceive(path: String, name: String?) async throws(FJRouterEventAction.CreateError) -> AnyPublisher<FJRouter.EventMatchInfo, Never> {
        let action = try FJRouterEventAction(path: path, name: name)
        let listener = await store.saveOrCreateListener(action: action)
        return listener.publisher()
    }

    func emit(_ location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.EmitEventError) {
        guard let url = URL(string: location) else {
            throw FJRouter.EmitEventError.errorLocUrl
        }
        guard let (listener, info) = await store.match(url: url, extra: extra) else {
            throw FJRouter.EmitEventError.notFind
        }
        listener.receive(value: info)
    }
    
    func emit(name: String, params: [String : String], queryParams: [String : String], extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.EmitEventError) {
        do {
            let loc =  try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
            try await emit(loc, extra: extra)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.EmitEventError.convertNameLoc(err)
            } else if let err = error as? FJRouter.EmitEventError {
                throw err
            } else {
                throw FJRouter.EmitEventError.cancelled
            }
        }
    }
}
