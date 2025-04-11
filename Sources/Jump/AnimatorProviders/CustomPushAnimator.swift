//
//  CustomPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/1.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension FJRoute {
    /// 使用自定义转场动画进行push
    ///
    /// ⚠️⚠️⚠️: 使用此方法的时候, 请不要在`viewController`内部设置`navigationController?.delegate = xxx`⚠️⚠️⚠️
    public struct CustomPushAnimator: FJRouteAnimator {
        /// 转场动画
        public typealias Animator = @MainActor @Sendable (_ info: AnimatorInfo) -> any UIViewControllerAnimatedTransitioning
        /// 交互
        public typealias Interactive = @MainActor @Sendable (_ animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)?

        /// push转场动画信息
        public struct AnimatorInfo: Sendable {
            public let operation: UINavigationController.Operation
            public let fromVC: UIViewController
            public let toVC: UIViewController
        }
        
        private let private_customPushAnimator: Private_CustomPushAnimator
        
        /// 初始化
        ///
        /// ⚠️⚠️⚠️: 使用此方法的时候, 请不要在`viewController`内部设置`navigationController?.delegate = xxx`⚠️⚠️⚠️
        /// - Parameters:
        ///   - animator: 自定义转场动画
        ///   - interactive: 转场动画的交互
        ///   - config: push设置
        public init(
            animator: @escaping FJRoute.CustomPushAnimator.Animator,
            interactive: Interactive?,
            config: PushAnimatorConfig = PushAnimatorConfig()
        ) {
            private_customPushAnimator = FJRoute.Private_CustomPushAnimator(
                animator: animator,
                interactive: interactive,
                config: config
            )
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            private_customPushAnimator.startAnimatedTransitioning(from: fromVC, to: toVC, state: matchState)
        }
    }
}

#endif
