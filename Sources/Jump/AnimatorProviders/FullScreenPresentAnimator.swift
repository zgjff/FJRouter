//
//  FullScreenPresentAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/1.
//

import Foundation
#if canImport(UIKit)
import UIKit

extension FJRoute {
    /// 自定义`fullScreen`的`present`转场动画
    public struct FullScreenPresentAnimator: FJRouteAnimator {
        /// 转场动画
        public typealias Animator = @MainActor @Sendable (_ info: AnimatorInfo) -> any UIViewControllerAnimatedTransitioning
        /// 交互
        public typealias Interactive = @MainActor @Sendable (_ presentordismiss: Bool, _ animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)?
        
        
        /// present转场动画信息
        public enum AnimatorInfo: @unchecked Sendable {
            /// present
            ///
            /// fromVC: 真正转场动画上下文中要动画的控制器
            ///
            /// source: 调用present(_:animated:completion:)方法的视图控制器
            ///
            /// fromVC与source可能相同, 也可能不同。不同的情况, 一般出现在source具有parent, 比如:
            ///
            /// 1: 在不带导航控制器的A内调用present(_:animated:completion:), 此时fromVC与source相同, 都是A
            ///
            /// 2: 带导航控制器的B内调用present(_:animated:completion:), 此时fromVC与source不同,
            /// fromVC是UINavigationController, 是真正参与转场动画的控制器, source是B
            case present(fromVC: UIViewController, source: UIViewController, toVC: UIViewController)
            /// dismiss
            case dismiss(UIViewController)
        }
        
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

extension FJRoute.FullScreenPresentAnimator {
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
            animator(.present(fromVC: presenting, source: source, toVC: presented))
        }
        
        func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
            animator(.dismiss(dismissed))
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
    fileprivate var fjroute_custom_present_uHBvZ$zAmEIWonLreDu6cC_delegate: FJRoute.FullScreenPresentAnimator.TransitionDelegate? {
        get {
            return objc_getAssociatedObject(self, &fjroute_custom_present_pK8bfsKJ4Fjb3h_uCN86_delegate_key) as? FJRoute.FullScreenPresentAnimator.TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &fjroute_custom_present_pK8bfsKJ4Fjb3h_uCN86_delegate_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

#endif
