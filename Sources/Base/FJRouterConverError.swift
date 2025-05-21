//
//  FJRouterConverError.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/5.
//

import Foundation

extension FJRouter {
    /// 通过路由/事件/资源名称、路由参数、查询参数组装路由路径错误
    public enum ConvertError: Error, @unchecked Sendable, Equatable {
        /// 不存在当前名称的路由/事件/资源名称
        case noExistName
        /// `URL`转换成`string`错误, 具体请看`URLComponents`的`string`注释
        case urlConvert
        /// 缺少参数
        case missingParameters(_ name: String)
    }
}

extension FJRouter.ConvertError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public nonisolated var description: String {
        switch self {
        case .noExistName:
            return "没有存储此name"
        case .urlConvert:
            return "url生成错误, 请查看URLComponents 的 string"
        case .missingParameters(let name):
            return "缺少参数: \(name)"
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
