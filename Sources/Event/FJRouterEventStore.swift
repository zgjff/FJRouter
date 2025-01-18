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
        private var nameToPath: [String: String] = [:]
    }
}

extension FJRouter.EventStore {
    @discardableResult
    func saveOrCreateListener(action: FJRouterEventAction) -> FJRouter.EventListener {
        guard let obj = listeners.first(where: { $0.action == action }) else {
            let listener = FJRouter.EventListener(action: action)
            listeners.insert(listener)
            return listener
        }
        guard let name = action.name else {
            return obj
        }
        guard let oldName = obj.action.name else {
            obj.updateActionName(name)
            return obj
        }
        assert(oldName != name, "不能监控path相同, 但是name却不相同的事件")
        return obj
    }
    
    func match(url: URL, extra: (any Sendable)?) -> (listener: FJRouter.EventListener, info: FJRouter.EventMatchInfo)? {
        let fixUrl = url.adjust()
        for listener in listeners {
            if let info = findMatch(url: fixUrl, extra: extra, action: listener.action) {
                return (listener, info)
            }
        }
        return nil
    }
    
    func numbers() -> Int {
        listeners.count
    }
}

private extension FJRouter.EventStore {
    func beginSaveActionNamePath(action: FJRouterEventAction) {
        
    }
    func findMatch(url: URL, extra: (any Sendable)?, action: FJRouterEventAction) -> FJRouter.EventMatchInfo? {
        guard let pairs = FJRouter.EventMatch.match(action: action, byUrl: url) else {
            return nil
        }
        return .init(url: url, matchedLocation: pairs.match.matchedLocation, action: pairs.match.action, pathParameters: pairs.pathParameters, queryParameters: url.queryParams, extra: extra)
    }
}
