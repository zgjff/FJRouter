//
//  FJRouteTargetBuilderInfo.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

extension FJRouteTarget {
    /// 路由动画构建信息
    public struct BuilderInfo: Sendable {
        /// 要跳转到的源控制器
        public let fromVC: IViewController?
        // TODO: - 替换
        /// 匹配到的路由信息
//        public let matchState: FJRouterState
    }
}
