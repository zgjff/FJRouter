//
//  CustomFullScreenPresentAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/1.
//

import Foundation
import UIKit

extension FJRoute {
    /// 自定义`fullScreen`的`present`转场动画
    public struct CustomFullScreenPresentAnimator: FJRouteAnimator {
        /// 转场动画
        public typealias Animator = @MainActor @Sendable (_ presentordismiss: Bool) -> any UIViewControllerAnimatedTransitioning
        /// 交互
        public typealias Interactive = @MainActor @Sendable (_ presentordismiss: Bool, _ animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)?
        private let useNavigationController: UINavigationController?
        private let animator: Animator
        private let interactive: Interactive?
        
        /// 初始化
        /// - Parameters:
        ///   - animator: 动画
        ///   - interactive: 交互
        ///   - useNavigationController: 使用导航栏包裹控制器. 注意navigationController必须是新初始化生成的
        public init(
            animator: @escaping Animator,
            interactive: Interactive?,
            navigationController useNavigationController: UINavigationController? = nil
        ) {
            self.animator = animator
            self.interactive = interactive
            self.useNavigationController = useNavigationController
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            var destVC = toVC
            if let useNavigationController {
                useNavigationController.setViewControllers([toVC], animated: false)
                destVC = useNavigationController
            }
            destVC.modalPresentationStyle = .fullScreen
            destVC.fjroute_custom_present_uHBvZ$zAmEIWonLreDu6cC_delegate = TransitionDelegate(
                animator: animator,
                interactive: interactive
            )
            destVC.transitioningDelegate = destVC.fjroute_custom_present_uHBvZ$zAmEIWonLreDu6cC_delegate
            fromVC?.present(destVC, animated: true)
        }
    }
}

extension FJRoute.CustomFullScreenPresentAnimator {
    fileprivate final class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
        private let animator: Animator
        private let interactive: Interactive?
        init(
            animator: @escaping Animator,
            interactive: Interactive?
        ) {
            self.animator = animator
            self.interactive = interactive
            super.init()
        }
        
        func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
            animator(true)
        }
        
        func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
            animator(false)
        }
        
        func interactionControllerForPresentation(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
            interactive?(true, animator)
        }
        
        func interactionControllerForDismissal(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
            interactive?(false, animator)
        }
    }
}

@MainActor private var fjroute_custom_present_pK8bfsKJ4Fjb3h_uCN86_delegate_key = 0
extension UIViewController {
    fileprivate var fjroute_custom_present_uHBvZ$zAmEIWonLreDu6cC_delegate: FJRoute.CustomFullScreenPresentAnimator.TransitionDelegate? {
        get {
            return objc_getAssociatedObject(self, &fjroute_custom_present_pK8bfsKJ4Fjb3h_uCN86_delegate_key) as? FJRoute.CustomFullScreenPresentAnimator.TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &fjroute_custom_present_pK8bfsKJ4Fjb3h_uCN86_delegate_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
