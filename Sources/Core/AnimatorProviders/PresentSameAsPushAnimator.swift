//
//  PresentSameAsPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/13.
//

import Foundation
import UIKit

extension FJRoute {
    /// 系统push/pop动画风格的present/dismiss转场动画, 支持侧滑dismiss
    public struct PresentSameAsPushAnimator: FJRouteAnimator {
        private let useNavigationController: UINavigationController?
        private let sideslipBack: Bool
        /// 初始化
        /// - Parameters:
        ///   - useNavigationController: 使用导航栏包裹控制器. 注意navigationController必须是新初始化生成的
        ///   - sideslipBack: 是否需要新页面支持手机边缘侧滑返回功能
        public init(navigationController useNavigationController: UINavigationController? = nil, sideslipBack: Bool = true) {
            self.useNavigationController = useNavigationController
            self.sideslipBack = sideslipBack
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            if sideslipBack {
                toVC.fjroute_addScreenPanGestureDismiss()
            }
            var destVC = toVC
            if let useNavigationController {
                useNavigationController.setViewControllers([toVC], animated: false)
                destVC = useNavigationController
            }
            destVC.modalPresentationStyle = .fullScreen
            destVC.transitioningDelegate = toVC.fjroute_pushPopStylePresentDelegate
            fromVC?.present(destVC, animated: true)
        }
    }
}

@MainActor private var fjroute_pushPopStylePresentDelegateKey = 0
extension UIViewController {
    fileprivate var fjroute_pushPopStylePresentDelegate: SystemPushPopTransitionDelegate {
        get {
            if let associated = objc_getAssociatedObject(self, &fjroute_pushPopStylePresentDelegateKey) as? SystemPushPopTransitionDelegate { return associated }
            let associated = SystemPushPopTransitionDelegate()
            objc_setAssociatedObject(self, &fjroute_pushPopStylePresentDelegateKey, associated, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return associated
        }
        set {
            objc_setAssociatedObject(self, &fjroute_pushPopStylePresentDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate func fjroute_addScreenPanGestureDismiss() {
        let spGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(fjroute_onBeganEdgePanGestureBack(_:)))
        spGesture.edges = .left
        view.addGestureRecognizer(spGesture)
    }
    
    @IBAction fileprivate func fjroute_onBeganEdgePanGestureBack(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard case .began = sender.state else {
            return
        }
        if let navit = navigationController?.transitioningDelegate as? SystemPushPopTransitionDelegate {
            navit.targetEdge = .left
            navit.gestureRecognizer = sender
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if let t = transitioningDelegate as? SystemPushPopTransitionDelegate {
            t.targetEdge = .left
            t.gestureRecognizer = sender
            dismiss(animated: true, completion: nil)
            return
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
@MainActor fileprivate class SystemPushPopTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var gestureRecognizer: UIScreenEdgePanGestureRecognizer?
    public var targetEdge: UIRectEdge = .right
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PushPopPresentAnimator(edge: targetEdge)
        animator.transitionCompleted = { [weak self] in
            self?.targetEdge = .left
        }
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PushPopPresentAnimator(edge: targetEdge)
        animator.transitionCompleted = { [weak self] in
            self?.targetEdge = .left
        }
        return animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let ges = gestureRecognizer {
            return SystemPushPopTransition(gestureRecognizer: ges, edgeForDragging: targetEdge)
        } else {
            return nil
        }
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let ges = gestureRecognizer {
            return SystemPushPopTransition(gestureRecognizer: ges, edgeForDragging: targetEdge)
        } else {
            return nil
        }
    }
}

// MARK: - UIPercentDrivenInteractiveTransition
fileprivate final class SystemPushPopTransition: UIPercentDrivenInteractiveTransition {
    init(gestureRecognizer: UIScreenEdgePanGestureRecognizer, edgeForDragging edge: UIRectEdge) {
        assert(edge == .top || edge == .bottom || edge == .left || edge == .right, "targetEdge must be one of UIRectEdgeTop, UIRectEdgeBottom, UIRectEdgeLeft, or UIRectEdgeRight.")
        self.gestureRecognizer = gestureRecognizer
        self.edge = edge
        super.init()
        gestureRecognizer.addTarget(self, action: #selector(gestureRecongnizeDidUpdate(_:)))
    }
    
    private let gestureRecognizer: UIScreenEdgePanGestureRecognizer
    private let edge: UIRectEdge
    private weak var transitionContext: UIViewControllerContextTransitioning?
    deinit {
        // TODO: - swift 系统支持时打开
//         gestureRecognizer.removeTarget(self, action: #selector(gestureRecongnizeDidUpdate(_:)))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    @MainActor @IBAction private func gestureRecongnizeDidUpdate(_ sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            return
        case .changed:
            update(percentForGesture(sender))
        case .ended:
            if percentForGesture(sender) >= 0.5 {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }
    
    private func percentForGesture(_ sender: UIScreenEdgePanGestureRecognizer) -> CGFloat {
        guard let transitionContainerView = transitionContext?.containerView else { return 0 }
        let location = sender.location(in: transitionContainerView)
        
        let width = transitionContainerView.bounds.width
        let height = transitionContainerView.bounds.height
        
        switch edge {
        case .right:
            return (width - location.x) / width
        case .left:
            return location.x / width
        case .bottom:
            return (height - location.y) / height
        case .top:
            return location.y / height
        default:
            return 0
        }
    }
}

// MAKR: - UIViewControllerAnimatedTransitioning
@MainActor fileprivate final class PushPopPresentAnimator: NSObject {
    var transitionCompleted: (() -> ())?
    private var animator: UIViewImplicitlyAnimating?
    init(edge: UIRectEdge) {
        self.targetEdge = edge
        super.init()
    }
    private let targetEdge: UIRectEdge
}

extension PushPopPresentAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return (transitionContext?.isAnimated ?? true) ? 0.35 : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let anim = interruptibleAnimator(using: transitionContext)
        anim.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator {
            return animator
        }
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
            fatalError()
        }
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        var fromView, toView: UIView
        if transitionContext.responds(to: #selector(transitionContext.view(forKey:))) {
            fromView = transitionContext.view(forKey: .from) ?? fromVC.view!
            toView = transitionContext.view(forKey: .to) ?? toVC.view!
        } else {
            fromView = fromVC.view
            toView = toVC.view
        }
        let isPresenting = toVC.presentingViewController == fromVC
        let startFrame = transitionContext.initialFrame(for: fromVC)
        let endFrame = transitionContext.finalFrame(for: toVC)
        var offset: CGVector
        switch targetEdge {
        case .top:
            offset = CGVector(dx: 0, dy: 1)
        case .bottom:
            offset = CGVector(dx: 0, dy: -1)
        case .left:
            offset = CGVector(dx: 1, dy: 0)
        case .right:
            offset = CGVector(dx: -1, dy: 0)
        default:
            offset = CGVector()
            assert(false, "targetEdge must be one of UIRectEdgeTop, UIRectEdgeBottom, UIRectEdgeLeft, or UIRectEdgeRight.")
        }
        
        let isfullScreen = (isPresenting ? fromVC : toVC).modalPresentationStyle == .fullScreen
        if isPresenting {
            if isfullScreen {
                fromView.frame = startFrame
            }
            toView.frame = endFrame.offsetBy(dx: endFrame.width * offset.dx * -1, dy: endFrame.height * offset.dy * -1)
        } else {
            fromView.frame = startFrame
            if isfullScreen {
                toView.frame = endFrame.offsetBy(dx: endFrame.width * -0.3, dy: 0)
            }
        }
        
        if isPresenting {
            containerView.addSubview(toView)
        } else {
            if isfullScreen {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
        }
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            if isPresenting {
                toView.frame = endFrame
                if isfullScreen {
                    fromView.frame = startFrame.offsetBy(dx: startFrame.width * -0.3, dy: 0)
                } else {
                    if let fsv = fromView.superview {
                        fsv.frame = fsv.frame.offsetBy(dx: fsv.frame.width * -0.3, dy: 0)
                    }
                }
            } else {
                fromView.frame = startFrame.offsetBy(dx: startFrame.width * offset.dx, dy: startFrame.height * offset.dy)
                if isfullScreen {
                    toView.frame = endFrame
                } else {
                    if let tsv = toView.superview {
                        tsv.frame = tsv.frame.offsetBy(dx: tsv.frame.width * 0.3, dy: 0)
                    }
                }
            }
        }
        
        animator.addCompletion { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            if wasCancelled {
                if isfullScreen {
                    toView.removeFromSuperview()
                }
            }
            transitionContext.completeTransition(!wasCancelled)
        }
        self.animator = animator
        return animator
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        self.transitionCompleted?()
        self.animator = nil
    }
}
