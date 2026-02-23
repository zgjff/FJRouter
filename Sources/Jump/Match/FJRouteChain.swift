//
//  FJRouteChain.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/22.
//

import Foundation
/// 路由链路信息
public struct FJRouteChain: Sendable {
    /// 当前路由
    let route: any FJRouteTargetType
    /// 父路由链路
    let parents: [any FJRouteTargetType]
}
