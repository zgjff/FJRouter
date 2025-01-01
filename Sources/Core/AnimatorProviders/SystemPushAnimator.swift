//
//  SystemPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit
import Combine

extension FJRoute {
    /// 使用系统push进行显示
    ///
    /// ⚠️⚠️⚠️: 使用此方法的时候, 请不要在`viewController`内部设置`navigationController?.delegate = xxx`⚠️⚠️⚠️
    public struct SystemPushAnimator: FJRouteAnimator {
        private let private_CustomPushAnimator: Private_CustomPushAnimator

        /// 初始化
        ///
        /// ⚠️⚠️⚠️: 使用此方法的时候, 请不要在`viewController`内部设置`navigationController?.delegate = xxx`⚠️⚠️⚠️
        /// - Parameter hidesBottomBarWhenPushed: hidesBottomBarWhenPushed: 设置push时`hidesBottomBarWhenPushed`
        public init(hidesBottomBarWhenPushed: Bool = true) {
            private_CustomPushAnimator = Private_CustomPushAnimator(
                animator: nil,
                interactive: nil,
                hidesBottomBarWhenPushed: hidesBottomBarWhenPushed
            )
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            private_CustomPushAnimator.startAnimatedTransitioning(from: fromVC, to: toVC, state: matchState)
        }
    }
}
