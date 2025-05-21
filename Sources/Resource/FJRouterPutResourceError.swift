//
//  FJRouterPutResourceError.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/27.
//

import Foundation

extension FJRouter {
    /// 存放资源错误
    public enum PutResourceError: Error, @unchecked Sendable {
        /// 已经存在相同path的资源
        case exist
    }
}

extension FJRouter.PutResourceError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.exist, .exist):
            return true
        }
    }
}

extension FJRouter.PutResourceError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public nonisolated var description: String {
        switch self {
        case .exist:
            return "已经存在相同path的资源"
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
