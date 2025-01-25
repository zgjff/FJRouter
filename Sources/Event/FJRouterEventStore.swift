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
        guard let name = action.name else {
            return obj
        }
        guard obj.action.name != nil else {
            beginSaveActionNamePath(action: action)
            obj.updateActionName(name)
            return obj
        }
        beginSaveActionNamePath(action: action)
        return obj
    }
    
    func match(url: URL, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) -> (listener: FJRouter.EventListener, info: FJRouter.EventMatchInfo)? {
        let fixUrl = url.adjust()
        for listener in listeners {
            if let info = findMatch(url: fixUrl, extra: extra, action: listener.action) {
                return (listener, info)
            }
        }
        return nil
    }
    
    /// 通过路由名称、路由参数、查询参数组装路由路径
    ///
    /// 建议在使用路由的时候使用此方法来组装路由路径。
    ///
    /// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
    ///
    /// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
    ///
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    /// - Returns: 组装之后的路由路径
    func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) throws -> String {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let path = nameToPath[n] else {
            throw FJRouter.ConvertError.noExistName
        }
        let newParams = params.reduce([String: String]()) { partialResult, pairs in
            var f = partialResult
            f.updateValue(pairs.value, forKey: pairs.key)
            return f
        }
        let location = FJPathUtils.default.patternToPath(pattern: path, pathParameters: newParams)
        var cop = URLComponents(string: location)
        if !queryParams.isEmpty {
            var queryItems = cop?.queryItems ?? []
            for qp in queryParams {
                queryItems.append(URLQueryItem(name: qp.key, value: qp.value))
            }
            cop?.queryItems = queryItems
        }
        guard let final = cop?.string else {
            throw FJRouter.ConvertError.urlConvert
        }
        guard final.count > 1 else {
            return final
        }
        if queryParams.isEmpty && path.hasSuffix("/") && !final.hasSuffix("/") {
            return final + "/"
        }
        if queryParams.isEmpty && !path.hasSuffix("/") && final.hasSuffix("/") {
            let result = final.dropLast()
            return String(result)
        }
        return final
    }
    
    func numbers() -> Int {
        listeners.count
    }
}

private extension FJRouter.EventStore {
    func beginSaveActionNamePath(action: FJRouterEventAction) {
        guard let name = action.name else {
            return
        }
        let fullPath = FJPathUtils.default.concatenatePaths(parentPath: "", childPath: action.path)
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
        return .init(url: url, matchedLocation: pairs.match.matchedLocation, action: pairs.match.action, pathParameters: pairs.pathParameters, queryParameters: url.queryParams, extra: extra())
    }
}
