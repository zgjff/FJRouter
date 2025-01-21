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
    func emit(_ location: String, extra: (any Sendable)?) throws
    
    /// 通过事件名称触发事件
    /// - Parameters:
    ///   - name: 事件名称
    ///   - extra: 携带的参数
    func emit(byName name: String, extra: (any Sendable)?) throws
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
    public func emit(_ location: String) throws {
        try emit(location, extra: nil)
    }
    
    /// 通过事件名称触发事件
    /// - Parameters:
    ///   - name: 事件名称
    public func emit(byName name: String) throws {
        try emit(byName: name, extra: nil)
    }
}
