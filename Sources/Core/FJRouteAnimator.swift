//
//  FJRouteAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

/// 显示匹配路由控制器的动画协议
public protocol FJRouteAnimator: Sendable {
    /// 开始路由转场动画
    /// - Parameters:
    ///   - fromVC: 要跳转到的源控制器
    ///   - toVC: 匹配到的路由指向的控制器
    ///   - matchState: 匹配到的路由信息
    @MainActor func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState)
}

extension FJRoute {
    /// 路由动画信息
    public struct AnimatorInfo: Sendable {
        /// 要跳转到的源控制器
        public let fromVC: UIViewController?
        /// 匹配到的路由指向的控制器
        public let toVC: UIViewController
        /// 匹配到的路由信息
        public let matchState: FJRouterState
    }
}
