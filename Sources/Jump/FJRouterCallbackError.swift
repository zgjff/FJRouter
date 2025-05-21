//
//  FJRouterEmitCallbackError.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation

extension FJRouter {
    /// 触发路由回调错误
    public enum EmitCallbackError: Error, @unchecked Sendable {
        /// 发送的`callback`的`name`为空
        case emptyName
        /// 没有路由回调触发器, 使用路由方法错误, 请使用带有`AnyPublisher`返回值的go方法
        case noTrigger
    }
}

extension FJRouter.EmitCallbackError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.emptyName, .emptyName):
            return true
        case (.noTrigger, .noTrigger):
            return true
        case (.emptyName, .noTrigger), (.noTrigger, .emptyName):
            return false
        }
    }
}

extension FJRouter.EmitCallbackError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public nonisolated var description: String {
        switch self {
        case .emptyName:
            return "send name is empty"
        case .noTrigger:
            return "please use async go method with return AnyPublisher"
        }
    }
    
    public var debugDescription: String {
        description
    }
    
    public var localizedDescription: String {
        description
    }
    
    public var errorDescription: String? {
        description
    }
    
    public var failureReason: String? {
        description
    }
}
