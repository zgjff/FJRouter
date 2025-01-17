//
//  FJRouterEventStore.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    internal actor EventStore {
        private var listeners: Set<EventListener> = []
    }
}

extension FJRouter.EventStore {
    @discardableResult
    func saveOrCreateListener(action: FJRouterEventAction) -> FJRouter.EventListener {
        if let obj = listeners.first(where: { $0.action == action }) {
            return obj
        }
        let listener = FJRouter.EventListener(action: action)
        listeners.insert(listener)
        return listener
    }
    
    func match(url: URL, extra: (any Sendable)?) -> FJRouter.EventMatch? {
        for listener in listeners {
            let _ = FJRouter.EventMatch.match(action: listener.action, byUrl: url)
//            return result?.match
        }
        return nil
    }
    
    func numbers() -> Int {
        listeners.count
    }
}

private extension FJRouter.EventStore {
    
}
