//
//  FJRouterEmitEventError.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/27.
//

import Foundation

extension FJRouter {
    /// 触发事件错误
    public enum EmitEventError: Error, @unchecked Sendable {
        /// 错误的查找路径: 不是正确的`URL`
        case errorLocUrl
        /// 没有发现: 没有监听过此path的事件
        case notFind
        /// 通过路由名称、路由参数、查询参数组装路由路径错误
        case convertNameLoc(_ error: (FJRouter.ConvertError))
        /// 提前取消匹配: async中Task{ .... }, 提前取消task
        case cancelled
    }
}

extension FJRouter.EmitEventError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.errorLocUrl, .errorLocUrl):
            return true
        case (.notFind, .notFind):
            return true
        case let (.convertNameLoc(le), .convertNameLoc(re)):
            return le == re
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }
}

extension FJRouter.EmitEventError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .errorLocUrl:
            return "传递的查询loc不是正确的URL"
        case .notFind:
            return "没有查询到相关事件"
        case .convertNameLoc(let err):
            return "转换查询name到loc错误: \(err)"
        case .cancelled:
            return "提前取消async Task"
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
