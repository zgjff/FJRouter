//
//  Private_CustomPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2025/4/11.
//

#if canImport(UIKit)
import Foundation
import Combine
import UIKit

extension FJRoute {
    internal struct Private_CustomPushAnimator: FJRouteAnimator {
        private let config: PushAnimatorConfig
        private let animator: FJRoute.CustomPushAnimator.Animator?
        private let interactive: FJRoute.CustomPushAnimator.Interactive?
        internal init(
            animator: FJRoute.CustomPushAnimator.Animator?,
            interactive: FJRoute.CustomPushAnimator.Interactive?,
            config: PushAnimatorConfig = PushAnimatorConfig()
        ) {
            self.config = config
            self.animator = animator
            self.interactive = interactive
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            guard let fromVC else {
                return
            }
            guard let finalNavi = checkNavigationController(from: fromVC) else {
                return
            }
            guard let fptedvc = finalNavi.presentedViewController else {
                doPush(from: finalNavi, to: toVC)
                return
            }
            switch config.ptedAction {
            case .push:
                doPush(from: finalNavi, to: toVC)
            case .none:
                return
            case .dismiss(animated: let flag):
                fptedvc.dismiss(animated: flag) { [finalNavi, toVC] in
                    self.doPush(from: finalNavi, to: toVC)
                }
            case .custom(action: let action):
                action(fptedvc, { [finalNavi, toVC] in
                    self.doPush(from: finalNavi, to: toVC)
                })
            }
        }
        
        @MainActor private func checkNavigationController(from fromVC: UIViewController) -> UINavigationController? {
            if fromVC is UINavigationController {
                return fromVC as! UINavigationController
            }
            if let navi = fromVC.navigationController {
                return navi
            }
            if let fp = fromVC.parent {
                if let fpnavi = fp as? UINavigationController {
                    return fpnavi
                }
                if let navi = checkNavigationController(from: fp) {
                    return navi
                }
                return nil
            }
            if let fptingvc = fromVC.presentingViewController {
                if let ftnavi = fptingvc as? UINavigationController {
                    return ftnavi
                }
                if let navi = checkNavigationController(from: fptingvc) {
                    return navi
                }
                return nil
            }
            return nil
        }
        
        @MainActor private func doPush(from navi: UINavigationController, to toVC: UIViewController) {
            let nd = NavigationDelegateBrigde(
                primary: navi.delegate,
                primaryIsSameType: navi.visibleViewController?.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge != nil,
                animator: animator,
                interactive: interactive
            )
            toVC.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge = nd
            toVC.hidesBottomBarWhenPushed = config.hidesBottomBarWhenPushed
            navi.delegate = toVC.fjroute_push_navigation_uHBvZ$zAmEIWonLreDu6cC_delegate_bridge?.delegate
            navi.pushViewController(toVC, animated: true)
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
