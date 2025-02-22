//
//  FJRouterJumpStore.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation

extension FJRouter {
    internal actor JumpStore {
        private var routes: [FJRoute] = []
        private var redirectLimit: UInt = 5
        private var nameToPath: [String: String] = [:]
    }
}

extension FJRouter.JumpStore {
    /// 添加新路由
    /// - Parameter route: 要添加的路由
    func addRoute(_ route: FJRoute) {
        routes.append(route)
        beginSaveRouteNamePath(parentFullPath: "", childRoutes: [route])
    }
    
    /// 设置允许重定向的次数
    /// - Parameter limit: 次数
    func setRedirectLimit(_ limit: UInt) {
        redirectLimit = max(1, limit)
    }
    
    /// 是否可以打开url
    /// - Parameter url: 路由url
    /// - Returns: 结果
    func canOpen(url: URL) -> Bool {
        let matchList = findMatch(url: url.adjust(), extra: nil)
        return !matchList.isError
    }
    
    /// 通过`url`查找匹配结果
    /// - Parameters:
    ///   - url: 准备查找的`url`
    ///   - extra: 携带的参数
    ///   - ignoreError: 是否忽略匹配失败。 true: 当没有匹配到的时候抛出错误, false: 当没有匹配到的时候不抛出错误
    /// - Returns: 匹配结果
    func match(url: URL, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, ignoreError: Bool) async throws -> FJRouteMatchList {
        let result = findMatch(url: url.adjust(), extra: extra)
        let final = await redirect(initialMatches: result)
        switch final.result {
        case .success(let ms):
            if ms.isEmpty && ignoreError {
                throw FJRouter.JumpMatchError.notFind
            }
            return final
        case .error(let err):
            if !ignoreError {
                return final
            }
            switch err {
            case .empty:
                throw FJRouter.JumpMatchError.notFind
            case .redirectLimit(let desc):
                throw FJRouter.JumpMatchError.redirectLimit(desc: desc)
            case .loopRedirect(let desc):
                throw FJRouter.JumpMatchError.loopRedirect(desc: desc)
            }
        }
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
        return try FJPathUtils.default.convertNewUrlPath(from: path, params: params, queryParams: queryParams)
    }
}

private extension FJRouter.JumpStore {
    func beginSaveRouteNamePath(parentFullPath: String, childRoutes: [FJRoute]) {
        for route in childRoutes {
            let fullPath = FJPathUtils.default.concatenatePaths(parentPath: parentFullPath, childPath: route.path)
            if let name = route.name {
                if nameToPath.keys.contains(name) {
                    let prefullpath = nameToPath[name]
                    assert(prefullpath == fullPath, "不能添加相同的路由名称: name: \(name), newfullpath: \(fullPath), oldfullpath: \(String(describing: prefullpath))")
                }
                nameToPath.updateValue(fullPath, forKey: name)
            }
            if !route.routes.isEmpty {
                beginSaveRouteNamePath(parentFullPath: fullPath, childRoutes: route.routes)
            }
        }
    }
    
    func findMatch(url: URL, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) -> FJRouteMatchList {
        let (matches, pathParameters) = getLocRouteMatches(url: url)
        if matches.isEmpty {
            return FJRouteMatchList(error: .empty, url: url, extra: extra())
        }
        return FJRouteMatchList(success: matches, url: url, pathParameters: pathParameters, extra: extra())
    }
    
    func getLocRouteMatches(url: URL) -> (matches: [FJRouteMatch], pathParameters: [String: String]) {
        for route in routes {
            let result = FJRouteMatch.match(route: route, byUrl: url)
            if !result.matches.isEmpty {
                return result
            }
        }
        return ([], [:])
    }
    
    func redirect(initialMatches: FJRouteMatchList) async -> FJRouteMatchList {
        let (match, _) = await tryRedirect(prevMatchList: initialMatches, redirectHistory: [])
        if match.isError {
            return match
        }
        return match
    }

    func tryRedirect(prevMatchList: FJRouteMatchList, redirectHistory: [FJRouteMatchList]) async -> (match: FJRouteMatchList, redirectHistory: [FJRouteMatchList]) {
        guard !prevMatchList.isError else {
            return (prevMatchList, redirectHistory)
        }
        guard let redirectLocation = await redirectLocationFor(matchList: prevMatchList),
              let redirectLocationUrl = URL(string: redirectLocation) else {
            return (prevMatchList, redirectHistory)
        }
        let newMatch = findMatch(url: redirectLocationUrl, extra: nil)
        do {
            let newRedirectHistory = try addRedirect(history: redirectHistory, newMatch: newMatch)
            return await tryRedirect(prevMatchList: newMatch, redirectHistory: newRedirectHistory)
        } catch {
            if let err = error as? FJRouteMatchList.MatchError {
                let errorMatch = FJRouteMatchList(error: err, url: prevMatchList.url, extra: nil)
                return (errorMatch, [])
            }
            let errorMatch = FJRouteMatchList(error: FJRouteMatchList.MatchError.empty, url: prevMatchList.url, extra: nil)
            return (errorMatch, [])
        }
    }
    
    func redirectLocationFor(matchList: FJRouteMatchList) async -> String? {
        guard let match = matchList.lastMatch else {
            return nil
        }
        guard let redirector = match.route.redirect else {
            return nil
        }
        let state = FJRouterState(matches: matchList)
        guard let redirectLocation = try? await redirector.redirectRoute(state: state) else {
            return nil
        }
        let prevLocation = matchList.url.absoluteString
        guard !redirectLocation.isEmpty, redirectLocation != prevLocation else {
            return nil
        }
        return redirectLocation
    }
    
    func addRedirect(history: [FJRouteMatchList], newMatch: FJRouteMatchList) throws -> [FJRouteMatchList] {
        var newRedirectHistory = history
        newRedirectHistory.append(newMatch)
        if history.count >= redirectLimit {
            let desc = newRedirectHistory.map({ $0.url.absoluteString }).joined(separator: " => ")
            throw FJRouteMatchList.MatchError.redirectLimit(desc: desc)
        }
        if history.contains(where: { $0.isSameOutExtra(with: newMatch) }) {
            let desc = newRedirectHistory.map({ $0.url.absoluteString }).joined(separator: " => ")
            throw FJRouteMatchList.MatchError.loopRedirect(desc: desc)
        }
        return newRedirectHistory
    }
}
