//
//  FJRouter+Event.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import Combine

extension FJRouter {
    /// 事件总线管理中心
    public static func event() -> any FJRouterEventable {
        FJRouter.EventImpl.shared
    }
}

/// 事件总线协议
public protocol FJRouterEventable {
    /// 监听事件
    /// - Parameter path: 事件路径path
    ///   - name: 事件名称
    func onReceive(path: String, name: String?) async throws -> AnyPublisher<FJRouter.EventMatchInfo, Never>
    
    /// 通过事件url路径触发事件
    /// - Parameters:
    ///   - location: 路径.
    ///   - extra: 携带的参数
    func emit(_ location: String, extra: (any Sendable)?) async throws
    
    /// 通过事件名称触发事件
    /// - Parameters:
    ///   - name: 事件名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    ///   - extra: 携带的参数
    func emit(byName name: String, params: [String : String], queryParams: [String : String], extra: (any Sendable)?) async throws
}

extension FJRouterEventable {
    /// 监听事件
    /// - Parameter path: 事件路径path
    ///   - name: 事件名称
    public func onReceive(path: String) async throws -> AnyPublisher<FJRouter.EventMatchInfo, Never> {
        try await onReceive(path: path, name: nil)
    }
    
    /// 通过事件url路径触发事件
    /// - Parameters:
    ///   - location: 路径
    public func emit(_ location: String) async throws {
        try await emit(location, extra: nil)
    }
    
    /// 通过事件名称触发事件
    /// - Parameters:
    ///   - name: 事件名称
    public func emit(byName name: String) async throws {
        try await emit(byName: name, params: [:], queryParams: [:], extra: nil)
    }
    
    /// 通过事件名称触发事件
    /// - Parameters:
    ///   - name: 事件名称
    ///   - params: 路由参数
    public func emit(byName name: String, params: [String : String]) async throws {
        try await emit(byName: name, params: params, queryParams: [:], extra: nil)
    }
    
    /// 通过事件名称触发事件
    /// - Parameters:
    ///   - name: 事件名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    public func emit(byName name: String, params: [String : String], queryParams: [String : String]) async throws {
        try await emit(byName: name, params: params, queryParams: queryParams, extra: nil)
    }
}
