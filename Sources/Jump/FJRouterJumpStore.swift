//
//  FJRouterJumpStore.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

#if canImport(UIKit)
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
    func match(url: URL, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, ignoreError: Bool) async throws(FJRouter.JumpMatchError) -> FJRouteMatchList {
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
            case .guardInterception:
                throw FJRouter.JumpMatchError.guardInterception
            case .redirectLimit(let desc):
                throw FJRouter.JumpMatchError.redirectLimit(desc: desc)
            case .loopRedirect(let desc):
                throw FJRouter.JumpMatchError.loopRedirect(desc: desc)
            }
        }
    }
    
    func convertLocation(by uri: FJRouter.URI) throws(FJRouter.ConvertError) -> String {
        return try uri.finalLocation { name in
            self.nameToPath[name]
        }
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
        let redirectAction = await redirectActionFor(matchList: prevMatchList)
        switch redirectAction {
        case .interception:
            let errorMatch = FJRouteMatchList(error: .guardInterception, url: prevMatchList.url, extra: nil)
            return (errorMatch, redirectHistory)
        case .original:
            return (prevMatchList, redirectHistory)
        case .new(let np):
            guard let redirectLocation = np, let redirectLocationUrl = URL(string: redirectLocation) else {
                return (prevMatchList, redirectHistory)
            }
            let newMatch = findMatch(url: redirectLocationUrl, extra: nil)
            do {
                let newRedirectHistory = try addRedirect(history: redirectHistory, newMatch: newMatch)
                return await tryRedirect(prevMatchList: newMatch, redirectHistory: newRedirectHistory)
            } catch {
                let errorMatch = FJRouteMatchList(error: error, url: prevMatchList.url, extra: nil)
                return (errorMatch, [])
            }
        }
    }
    
    func redirectActionFor(matchList: FJRouteMatchList) async -> FJRouteRedirectorNext {
        guard let match = matchList.lastMatch else {
            return .original
        }
        guard let redirector = match.route.redirect else {
            return .original
        }
        let state = FJRouterState(matches: matchList)
        return await redirector.redirectRouteNext(state: state)
    }
    
    func addRedirect(history: [FJRouteMatchList], newMatch: FJRouteMatchList) throws(FJRouteMatchList.MatchError) -> [FJRouteMatchList] {
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

#endif
