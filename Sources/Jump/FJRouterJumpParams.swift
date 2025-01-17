//
//  FJRouterJumpParams.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import UIKit

// MARK: - 跳转
public enum FJRouterJumpParams {
    /// 通过路由路径进行跳转参数
    public struct GoLocation: Sendable {
        internal let path: String
        internal let extra: (any Sendable)?
        internal let fromVC: UIViewController?
        internal let ignoreError: Bool
        /// 初始化
        /// - Parameters:
        ///   - path: 路由路径
        ///   - extra: 携带的参数
        ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
        ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
        public init(path: String, extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) {
            self.path = path
            self.extra = extra
            self.fromVC = fromVC
            self.ignoreError = ignoreError
        }
    }
    
    /// 通过路由名称进行跳转参数
    public struct GoNamed: Sendable {
        internal let name: String
        internal let params: [String: String]
        internal let queryParams: [String: String]
        internal let extra: (any Sendable)?
        internal let fromVC: UIViewController?
        internal let ignoreError: Bool
        
        /// 初始化
        /// - Parameters:
        ///   - name: 路由名称
        ///   - params: 路由参数
        ///   - queryParams: 路由查询参数
        ///   - extra: 携带的参数
        ///   - fromVC: 源控制器, 若为nil, 则在框架内部获取app的top controller
        ///   - ignoreError: 是否忽略匹配失败时返回`errorBuilder`返回的控制器。true: 失败时不跳转至`error`页面
        public init(name: String, params: [String : String] = [:], queryParams: [String : String] = [:], extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) {
            self.name = name
            self.params = params
            self.queryParams = queryParams
            self.extra = extra
            self.fromVC = fromVC
            self.ignoreError = ignoreError
        }
        
        internal func convertToLocation(action: (_ name: String, _ params: [String : String], _ queryParams: [String : String]) async throws -> String) async rethrows -> GoLocation {
            let loc = try await action(name, params, queryParams)
            return .init(path: loc, extra: extra, from: fromVC, ignoreError: ignoreError)
        }
    }
}

// MARK: - find viewController
extension FJRouterJumpParams {
    /// 通过路由路径进行查找
    public struct FindControllerByLocation: Sendable {
        internal let path: String
        internal let extra: (any Sendable)?
        /// 初始化
        /// - Parameters:
        ///   - path: 路由路径
        ///   - extra: 携带的参数
        public init(path: String, extra: (any Sendable)? = nil) {
            self.path = path
            self.extra = extra
        }
    }
    
    /// 通过路由名称进行查找
    public struct FindControllerByNamed: Sendable {
        internal let name: String
        internal let params: [String: String]
        internal let queryParams: [String: String]
        internal let extra: (any Sendable)?
        
        /// 初始化
        /// - Parameters:
        ///   - name: 路由名称
        ///   - params: 路由参数
        ///   - queryParams: 路由查询参数
        ///   - extra: 携带的参数
        public init(name: String, params: [String : String] = [:], queryParams: [String : String] = [:], extra: (any Sendable)? = nil) {
            self.name = name
            self.params = params
            self.queryParams = queryParams
            self.extra = extra
        }
    }
}
