//
//  FJRouterJumpMatchError.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/5.
//

import Foundation

extension FJRouter {
    /// 路由跳转匹配错误
    public enum JumpMatchError: Error, @unchecked Sendable {
        /// 错误的查找路径: 不是正确的`URL`
        case errorLocUrl
        /// 没有发现路由: 没有注册过此path的路由
        case notFind
        /// 对应的路由没有builder: 出现在构建路由的时候没有`builder`参数, 只有`redirect`参数, 且`redirect`协议返回了`none`
        case noBuilder
        /// 路由守卫拦截
        case guardInterception
        /// 重定向次数超出限制
        case redirectLimit(desc: String)
        /// 循环重定向
        case loopRedirect(desc: String)
        /// 通过路由名称、路由参数、查询参数组装路由路径错误
        case convertNameLoc(_ error: (FJRouter.ConvertError))
        /// 提前取消匹配: async中Task{ .... }, 提前取消task
        case cancelled
    }
}

extension FJRouter.JumpMatchError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.errorLocUrl, .errorLocUrl):
            return true
        case (.notFind, .notFind):
            return true
        case (.noBuilder, .noBuilder):
            return true
        case (.guardInterception, .guardInterception):
            return true
        case let (.redirectLimit(ld), .redirectLimit(rd)):
            return ld == rd
        case let (.loopRedirect(ld), .loopRedirect(rd)):
            return ld == rd
        case let (.convertNameLoc(le), .convertNameLoc(re)):
            return le == re
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }
}

extension FJRouter.JumpMatchError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .errorLocUrl:
            return "Search loc url is correct URL"
        case .notFind:
            return "Does not find any route"
        case .noBuilder:
            return "Mathed Route has no builder"
        case .guardInterception:
            return "Match Route success, but route guard interception"
        case .redirectLimit(desc: let desc):
            return desc
        case .loopRedirect(desc: let desc):
            return desc
        case .convertNameLoc(let err):
            return "Convert name to loc error: \(err)"
        case .cancelled:
            return "Match task has cancelled"
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
