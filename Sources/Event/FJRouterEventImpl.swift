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
    func onReceive(uri: any FJRouterRegisterURI) async throws(FJRouter.RegisterURIError) -> AnyPublisher<FJRouter.EventMatchInfo, Never> {
        let action = try FJRouterEventAction(uri: uri)
        let listener = await store.saveOrCreateListener(action: action)
        return listener.publisher()
    }

    func emit(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.EmitEventError) {
        do {
            let loc = try await store.convertLocation(by: uri)
            guard let url = URL(string: loc) else {
                throw FJRouter.EmitEventError.errorLocUrl
            }
            guard let (listener, info) = await store.match(url: url, extra: extra) else {
                throw FJRouter.EmitEventError.notFind
            }
            listener.receive(value: info)
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
