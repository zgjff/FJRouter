//
//  FJRouterState.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
/// 匹配路由的状态
public struct FJRouterState: @unchecked Sendable {
    /// 要匹配的原始url
    public let url: URL
    /// 匹配到的内容字符串
    public let matchedLocation: String
    /// 匹配到的路由path, eg: family/:fid
    public let path: String?
    /// 匹配到的路由名称
    public let name: String?
    /// 路由的全路径
    public let fullPath: String
    /// 匹配到的参数
    public let pathParameters: [String: String]
    /// 携带的额外内容
    public let extra: Any?
    public let route: FJRoute?
    /// 错误信息
    let error: FJRouteMatchList.MatchError?
    
    init(matches: FJRouteMatchList) {
        url = matches.url
        matchedLocation = matches.url.versionPath
        path = nil
        name = nil
        fullPath = matches.fullPath
        pathParameters = matches.pathParameters
        extra = matches.extra
        route = matches.lastMatch?.route
        if case let .error(err) = matches.result {
            error = err
        } else {
            error = nil
        }
    }
    
    init(matches: FJRouteMatchList, match: FJRouteMatch) {
        url = matches.url
        matchedLocation = match.matchedLocation
        fullPath = matches.fullPath
        pathParameters = matches.pathParameters
        name = match.route.name
        path = match.route.path
        extra = matches.extra
        route = matches.lastMatch?.route
        error = nil
    }
}

extension FJRouterState {
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
    public func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) async -> String? {
        await FJRouter.shared.convertLocationBy(name: name, params: params, queryParams: queryParams)
    }
}