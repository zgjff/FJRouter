//
//  CustomPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/1.
//

import Foundation
import Combine
#if canImport(UIKit)
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
        ///   - hidesBottomBarWhenPushed: 设置push时`hidesBottomBarWhenPushed`
        public init(
            animator: @escaping FJRoute.CustomPushAnimator.Animator,
            interactive: Interactive?,
            hidesBottomBarWhenPushed: Bool = true
        ) {
            private_customPushAnimator = FJRoute.Private_CustomPushAnimator(
                animator: animator,
                interactive: interactive,
                hidesBottomBarWhenPushed: hidesBottomBarWhenPushed
            )
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            private_customPushAnimator.startAnimatedTransitioning(from: fromVC, to: toVC, state: matchState)
        }
    }
}

extension FJRoute {
    internal struct Private_CustomPushAnimator: FJRouteAnimator {
        private let hidesBottomBarWhenPushed: Bool
        private let animator: FJRoute.CustomPushAnimator.Animator?
        private let interactive: FJRoute.CustomPushAnimator.Interactive?
        internal init(
            animator: FJRoute.CustomPushAnimator.Animator?,
            interactive: FJRoute.CustomPushAnimator.Interactive?,
            hidesBottomBarWhenPushed: Bool = true
        ) {
            self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
            self.animator = animator
            self.interactive = interactive
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            let nd = NavigationDelegateBrigde(
                primary: fromVC?.navigationController?.delegate,
                primaryIsSameType: fromVC?.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge != nil,
                animator: animator,
                interactive: interactive
            )
            toVC.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge = nd
            fromVC?.navigationController?.delegate = toVC.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge?.delegate
            toVC.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
            fromVC?.navigationController?.pushViewController(toVC, animated: true)
        }
    }
}

extension FJRoute.Private_CustomPushAnimator {
    @MainActor fileprivate final class NavigationDelegateBrigde: Sendable {
        nonisolated(unsafe) var delegate: UINavigationControllerDelegate?
        nonisolated(unsafe) private var cancels: Set<AnyCancellable> = []
        private weak var primaryDelegate: UINavigationControllerDelegate?
        private let primaryIsSameType: Bool
        deinit {
            cancels = []
            delegate = nil
        }
        init(
            primary: UINavigationControllerDelegate?,
             primaryIsSameType: Bool,
             animator: FJRoute.CustomPushAnimator.Animator?,
             interactive: FJRoute.CustomPushAnimator.Interactive?
        ) {
            primaryDelegate = primary
            self.primaryIsSameType = primaryIsSameType
            if let animator {
                let d = CustomAnimator(
                    animator: animator,
                    interactive: interactive,
                    supportedInterfaceOrientations: { [weak self] navi in
                        return self?.navigationControllerSupportedInterfaceOrientations(navi) ?? .all
                    },
                    interfaceOrientationForPresentation: { [weak self] navi in
                        return self?.navigationControllerPreferredInterfaceOrientationForPresentation(navi) ?? .portrait
                    }
                )
                
                d.willShow.sink(receiveValue: { [weak self] pairs in
                    self?.navigationController(pairs.0, willShow: pairs.1, animated: pairs.2)
                }).store(in: &cancels)
                d.didShow.sink(receiveValue: { [weak self] pairs in
                    self?.navigationController(pairs.0, didShow: pairs.1, animated: pairs.2)
                }).store(in: &cancels)
                delegate = d
                return
            }
            let d = SystemAnimator(
                supportedInterfaceOrientations: { [weak self] navi in
                    return self?.navigationControllerSupportedInterfaceOrientations(navi) ?? .all
                },
                interfaceOrientationForPresentation: { [weak self] navi in
                    return self?.navigationControllerPreferredInterfaceOrientationForPresentation(navi) ?? .portrait
                }
            )
            d.willShow.sink(receiveValue: { [weak self] pairs in
                self?.navigationController(pairs.0, willShow: pairs.1, animated: pairs.2)
            }).store(in: &cancels)
            d.didShow.sink(receiveValue: { [weak self] pairs in
                self?.navigationController(pairs.0, didShow: pairs.1, animated: pairs.2)
            }).store(in: &cancels)
            delegate = d
        }
        
        private func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            primaryDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
        
        private func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            primaryDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
            if primaryIsSameType {
                return
            }
            if let nd = viewController.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge?.delegate {
                viewController.navigationController?.delegate = nd
            } else {
                viewController.navigationController?.delegate = primaryDelegate
            }
        }
        
        func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
            guard let primaryDelegate else {
                return .all
            }
            guard primaryDelegate.responds(to: #selector(primaryDelegate.navigationControllerSupportedInterfaceOrientations(_:))) else {
                return .all
            }
            return primaryDelegate.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
        }
        
        func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
            guard let primaryDelegate else {
                return .portrait
            }
            guard primaryDelegate.responds(to: #selector(primaryDelegate.navigationControllerPreferredInterfaceOrientationForPresentation(_:))) else {
                return .portrait
            }
            return primaryDelegate.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
        }
    }
}

extension FJRoute.Private_CustomPushAnimator.NavigationDelegateBrigde {
    fileprivate final class SystemAnimator: NSObject, UINavigationControllerDelegate {
        deinit {
            willShow.send(completion: .finished)
            didShow.send(completion: .finished)
        }
        init(
            supportedInterfaceOrientations: @escaping (UINavigationController) -> UIInterfaceOrientationMask, interfaceOrientationForPresentation: @escaping (UINavigationController) -> UIInterfaceOrientation
        ) {
            willShow = PassthroughSubject()
            didShow = PassthroughSubject()
            super.init()
            self.supportedInterfaceOrientations = supportedInterfaceOrientations
            self.interfaceOrientationForPresentation = interfaceOrientationForPresentation
        }
        
        nonisolated(unsafe) let willShow: PassthroughSubject<(UINavigationController, UIViewController, Bool), Never>
        nonisolated(unsafe) let didShow: PassthroughSubject<(UINavigationController, UIViewController, Bool), Never>
        private var supportedInterfaceOrientations: ((UINavigationController) -> UIInterfaceOrientationMask)?
        private var interfaceOrientationForPresentation: ((UINavigationController) -> UIInterfaceOrientation)?
        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            willShow.send((navigationController, viewController, animated))
        }
        
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            didShow.send((navigationController, viewController, animated))
        }
        
        func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
            supportedInterfaceOrientations?(navigationController) ?? .all
        }
        
        func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
            interfaceOrientationForPresentation?(navigationController) ?? .portrait
        }
    }
}

extension FJRoute.Private_CustomPushAnimator.NavigationDelegateBrigde {
    fileprivate final class CustomAnimator: NSObject, UINavigationControllerDelegate {
        deinit {
            willShow.send(completion: .finished)
            didShow.send(completion: .finished)
        }
        
        init(
            animator: @escaping FJRoute.CustomPushAnimator.Animator,
            interactive: FJRoute.CustomPushAnimator.Interactive?,
            supportedInterfaceOrientations: @escaping (UINavigationController) -> UIInterfaceOrientationMask,
            interfaceOrientationForPresentation: @escaping (UINavigationController) -> UIInterfaceOrientation
        ) {
            willShow = PassthroughSubject()
            didShow = PassthroughSubject()
            self.animator = animator
            self.interactive = interactive
            super.init()
            self.supportedInterfaceOrientations = supportedInterfaceOrientations
            self.interfaceOrientationForPresentation = interfaceOrientationForPresentation
        }
        let animator: FJRoute.CustomPushAnimator.Animator
        let  interactive: FJRoute.CustomPushAnimator.Interactive?
        nonisolated(unsafe) let willShow: PassthroughSubject<(UINavigationController, UIViewController, Bool), Never>
        nonisolated(unsafe) let didShow: PassthroughSubject<(UINavigationController, UIViewController, Bool), Never>
        private var supportedInterfaceOrientations: ((UINavigationController) -> UIInterfaceOrientationMask)?
        private var interfaceOrientationForPresentation: ((UINavigationController) -> UIInterfaceOrientation)?
        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            willShow.send((navigationController, viewController, animated))
        }
        
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            didShow.send((navigationController, viewController, animated))
        }
        
        func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
            supportedInterfaceOrientations?(navigationController) ?? .all
        }
        
        func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
            interfaceOrientationForPresentation?(navigationController) ?? .portrait
        }
        
        func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
            interactive?(animationController)
        }
        
        func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
            animator(FJRoute.CustomPushAnimator.AnimatorInfo(operation: operation, fromVC: fromVC, toVC: toVC))
        }
    }
}

@MainActor private var fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_key = 0
extension UIViewController {
    fileprivate var fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge: FJRoute.Private_CustomPushAnimator.NavigationDelegateBrigde? {
        get {
            return objc_getAssociatedObject(self, &fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_key) as? FJRoute.Private_CustomPushAnimator.NavigationDelegateBrigde
        }
        set {
            objc_setAssociatedObject(self, &fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

#endif
