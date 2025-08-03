//
//  FJRouteTargetBuilderInfo.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation
import UIKit

extension FJRouteTarget {
    /// 路由动画构建信息
    public struct BuilderInfo: Sendable {
        /// 要跳转到的源控制器
        public let fromVC: UIViewController?
        /// 匹配到的路由信息
        public let matchState: FJRouterState
    }
}
