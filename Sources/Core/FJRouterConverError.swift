//
//  FJRouterConverError.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/5.
//

import Foundation

extension FJRouter {
    /// 通过路由名称、路由参数、查询参数组装路由路径错误
    public enum ConvertError: Error, Sendable, Equatable {
        /// 不存在当前名称的路由
        case noExistName
        /// `URL`转换成`string`错误, 具体请看`URLComponents`的`string`注释
        case urlConvert
        /// 提前取消
        case cancelled
    }
}

extension FJRouter.ConvertError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .noExistName:
            return "Store has no route for this name"
        case .urlConvert:
            return "Can not get string from URLComponents"
        case .cancelled:
            return "Convert task has cancelled"
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
