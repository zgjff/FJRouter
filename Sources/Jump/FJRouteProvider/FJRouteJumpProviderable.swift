//
//  FJRouteJumpProviderable.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation
/// 路由跳转协议
public protocol FJRouteJumpProviderable: Sendable {
    /// 注册路由
    /// - Parameter target: 路由对象
    func registerRoute(_ target: any FJRouteTargetType) async
    
    /// 设置允许重定向的次数
    ///
    ///     await FJRouter.jump().setRedirectLimit(50)
    ///
    /// - Parameter limit: 次数
    func setRedirectLimit(_ limit: UInt) async
    
    @discardableResult
    func match(with extra: @autoclosure @escaping @Sendable () -> Any?) async throws(FJRouter.JumpMatchError) -> FJRouteJumpProvider.MatchResult
}
