//
//  FJRouterGetResourceError.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/28.
//

import Foundation

extension FJRouter {
    /// 获取资源错误
    public enum GetResourceError: Error, @unchecked Sendable {
        /// 错误的查找路径: 不是正确的`URL`
        case errorLocUrl
        /// 没有发现: 没有监听过此path的事件
        case notFind
        /// 通过路由名称、路由参数、查询参数组装路由路径错误
        case convertNameLoc(_ error: (FJRouter.ConvertError))
        /// value类型错误
        case valueType
        /// 提前取消匹配: async中Task{ .... }, 提前取消task
        case cancelled
    }
}

extension FJRouter.GetResourceError: Equatable {
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
        case (.valueType, .valueType):
            return true
        default:
            return false
        }
    }
}

//extension FJRouter.GetResourceError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
//    public var description: String {
//        switch self {
//        case .errorLocUrl:
//            return "Search loc url is correct URL"
//        case .notFind:
//            return "Does not find any event action"
//        case .convertNameLoc(let err):
//            return "Convert name to loc url error: \(err)"
//        case .valueType:
//            return "Get resource type dose not same put"
//        case .cancelled:
//            return "Match task has cancelled"
//        }
//    }
//    
//    public var debugDescription: String {
//        description
//    }
//    
//    public var localizedDescription: String {
//        description
//    }
//    
//    public var errorDescription: String? {
//        description
//    }
//    
//    public var failureReason: String? {
//        description
//    }
//}
