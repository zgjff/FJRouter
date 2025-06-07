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
            beginSaveActionNamePath(action: action)
            return listener
        }
        guard let name = action.uri.name else {
            return obj
        }
        guard obj.action.uri.name != nil else {
            beginSaveActionNamePath(action: action)
            obj.updateActionName(name)
            return obj
        }
        beginSaveActionNamePath(action: action)
        return obj
    }
    
    func match(url: URL, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) -> (listener: FJRouter.EventListener, info: FJRouter.EventMatchInfo)? {
        let fixUrl = url.fj.adjust()
        for listener in listeners {
            if let info = findMatch(url: fixUrl, extra: extra, action: listener.action) {
                return (listener, info)
            }
        }
        return nil
    }
    
    func convertLocation(by uri: FJRouter.URI) throws(FJRouter.ConvertError) -> String {
        try uri.finalLocation(in: nameToPath)
    }
    
    func numbers() -> Int {
        listeners.count
    }
}

private extension FJRouter.EventStore {
    func beginSaveActionNamePath(action: FJRouterEventAction) {
        guard let name = action.uri.name else {
            return
        }
        let fullPath = FJPathUtils.default.concatenatePaths(parentPath: "", childPath: action.uri.path)
        if nameToPath.keys.contains(name) {
            let prefullpath = nameToPath[name]
            /// 提前崩溃, 防止这种错误出现
            assert(prefullpath == fullPath, "不能添加名称相同但path却不同的事件: name: \(name), newfullpath: \(fullPath), oldfullpath: \(String(describing: prefullpath))")
        }
        nameToPath.updateValue(fullPath, forKey: name)
    }
    
    func findMatch(url: URL, extra: @escaping @Sendable () -> (any Sendable)?, action: FJRouterEventAction) -> FJRouter.EventMatchInfo? {
        guard let pairs = FJRouter.EventMatch.match(action: action, byUrl: url) else {
            return nil
        }
        return .init(url: url, matchedLocation: pairs.match.matchedLocation, action: pairs.match.action, pathParameters: pairs.pathParameters, queryParameters: url.fj.queryParams, extra: extra())
    }
}
