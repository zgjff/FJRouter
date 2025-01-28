//
//  FJRouter+Resource.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 资源中心
    public static func resource() -> any FJRouterResourceable {
        FJRouter.ResourceImpl.shared
    }
}

/// 资源协议
public protocol FJRouterResourceable {
    /// 存放资源
    /// - Parameter resource: 资源
    ///
    /// 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...
    func put(_ resource: FJRouterResource) async throws
    
    /// 根据资源路径取对应资源
    /// - Parameters:
    ///   - location: 资源路径
    ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
    /// - Returns: 对应资源
    func get<Value>(_ location: String, inMainActor mainActor: Bool) async throws -> Value where Value: Sendable
    
    /// 根据资源名称取对应资源
    /// - Parameters:
    ///   - name: 资源名称
    ///   - params: 资源path参数
    ///   - queryParams: 资源查询参数
    ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
    /// - Returns: 对应资源
    func get<Value>(name: String, params: [String : String], queryParams: [String : String], inMainActor mainActor: Bool) async throws -> Value where Value: Sendable
}
