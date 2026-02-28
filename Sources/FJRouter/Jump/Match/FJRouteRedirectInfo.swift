//
//  FJRouteRedirectInfo.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/22.
//

import Foundation
/// 路由重定向信息
public struct FJRouteRedirectInfo: Sendable {
    public let from: any FJRouteTargetType
    public let to: FJRouteChain
}
