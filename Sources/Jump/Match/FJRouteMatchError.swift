//
//  FJRouteMatchError.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/5.
//

import Foundation
/// 匹配路由失败
public enum FJRouteMatchError: Error, @unchecked Sendable {
    /// 未注册的路由
    case unRegister(_ route: any FJRouteTargetType)
}
