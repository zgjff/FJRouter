//
//  CustomPresentationAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

extension FJRoute {
    /// 自定义弹窗控制动画
    public struct CustomPresentationAnimator: FJRouteAnimator {
        private let config: ((_ ctx: FJCustomPresentationContext) -> ())?
        private let useNavigationController: UINavigationController?
        
        /// 初始化
        /// - Parameters:
        ///   - useNavigationController: 使用导航栏包裹控制器. 注意navigationController必须是新初始化生成的
        ///   - config: 配置
        public init(navigationController useNavigationController: UINavigationController? = nil, config: ((_ ctx: FJCustomPresentationContext) -> ())? = nil) {
            self.useNavigationController = useNavigationController
            self.config = config
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            guard let fromVC else {
                return
            }
            var destVC = toVC
            if let useNavigationController {
                useNavigationController.setViewControllers([toVC], animated: false)
                destVC = useNavigationController
            }
            let pd = FJCustomPresentationController(show: destVC, from: fromVC, config: config)
            fromVC.present(destVC, animated: true) {
                let _ = pd
            }
        }
    }
}

// MARK: - UIPresentationController
/// 弹窗驱动提供器,方便自定义弹窗弹出动画逻辑
fileprivate final class FJCustomPresentationController: UIPresentationController {
    /// 初始化弹窗驱动提供器
    /// - Parameters:
    ///   - presentedViewController: 跳转源控制器
    ///   - presentingViewController: 跳转目标控制器
    ///   - configContext: 设置context的block
    init(show presentedViewController: UIViewController, from presentingViewController: UIViewController?, config configContext: ((_ ctx: FJCustomPresentationContext) -> ())? = nil) {
        self.context = FJCustomPresentationContext()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
        configContext?(context)
    }
    override var presentedView: UIView? {
        return presentationWrappingView
    }
    private let context: FJCustomPresentationContext
    private var belowCoverView: UIView?
    private var presentationWrappingView: UIView?
}

extension FJCustomPresentationController {
    /// 更新动画协调器
    func updateContext(_ block: (_ ctx: FJCustomPresentationContext) -> ()) {
        block(context)
    }
    
    /// 开始present跳转
    /// - Parameters:
    ///   - animated: 动画与否
    ///   - completion: 跳转完成回调
    func startPresent(animated: Bool = true, completion: (() -> ())?) {
        presentingViewController.present(presentedViewController, animated: animated) {
            let _ = self
            completion?()
        }
    }
}

extension FJCustomPresentationController {
    override func presentationTransitionWillBegin() {
        do {
            guard let presentedViewControllerView = super.presentedView else { return }
            presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let f = frameOfPresentedViewInContainerView
            if let warps = context.presentationWrappingView?(presentedViewControllerView, f) {
                self.presentationWrappingView = warps
            } else {
                presentedViewControllerView.frame = f
                self.presentationWrappingView = presentedViewControllerView
            }
        }
        if context.presentingControllerTriggerAppearLifecycle.contains(.disappear) {
            presentingViewController.beginAppearanceTransition(false, animated: true)
        }
        do {
            // TODO: - 无belowCoverView时的手势
            guard let cb = context.belowCoverView,
            let cv = containerView else { return }
            let bcv = cb(cv.bounds)
            bcv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(belowCoverTapped(_:))))
            belowCoverView = bcv
            cv.addSubview(bcv)
            guard let coor = presentingViewController.transitionCoordinator else { return }
            context.willPresentAnimatorForBelowCoverView?(bcv, coor)
        }
    }
    
    @IBAction private func belowCoverTapped(_ sender: UITapGestureRecognizer) {
        switch context.belowCoverAction {
        case .autodismiss(let isDismiss):
            if isDismiss {
                presentingViewController.dismiss(animated: true, completion: nil)
            }
        case .customize(action: let block):
            block()
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if (completed) {
            if context.presentingControllerTriggerAppearLifecycle.contains(.disappear) {
                presentingViewController.endAppearanceTransition()
            }
        }
        if !completed {
            presentationWrappingView = nil
            belowCoverView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let belowView = belowCoverView,
        let coordinator = presentingViewController.transitionCoordinator else { return }
        if context.presentingControllerTriggerAppearLifecycle.contains(.appear) {
            presentingViewController.beginAppearanceTransition(true, animated: true)
        }
        context.willDismissAnimatorForBelowCoverView?(belowView, coordinator)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentationWrappingView = nil
            belowCoverView = nil
            if context.presentingControllerTriggerAppearLifecycle.contains(.appear) {
                presentingViewController.endAppearanceTransition()
            }
        }
    }
}

extension FJCustomPresentationController {
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        guard let vc = container as? UIViewController, vc == presentedViewController else {
            return
        }
        containerView?.setNeedsLayout()
        guard let config = context.preferredContentSizeDidChangeAnimationInfo else {
            containerView?.layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: config.duration, delay: config.delay, options: config.options) {
            self.containerView?.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let vc = container as? UIViewController, vc == presentedViewController {
            return vc.preferredContentSize
        }
        return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let cv = containerView else {
            return .zero
        }
        let s = size(forChildContentContainer: presentedViewController, withParentContainerSize: cv.bounds.size)
        return context.frameOfPresentedViewInContainerView?(cv.bounds, s) ?? CGRect(origin: .zero, size: s)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        if let cv = containerView {
            belowCoverView?.frame = cv.bounds
            presentationWrappingView?.frame = frameOfPresentedViewInContainerView
        }
    }
}

extension FJCustomPresentationController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(presented == presentedViewController, "presentedViewController设置错误")
        return self
    }
}

extension FJCustomPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if let ctx = transitionContext {
            return ctx.isAnimated ? context.duration : 0
        }
        return context.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        let cv = transitionContext.containerView
        let isPresenting = presentingViewController == fromVC
        let fromView = transitionContext.view(forKey: .from) ?? fromVC.view!
        let toView = transitionContext.view(forKey: .to) ?? toVC.view!
        
        let finitialFrame = transitionContext.initialFrame(for: fromVC)
        let ffinalFrame = transitionContext.finalFrame(for: fromVC)
        let tinitialFrame = transitionContext.initialFrame(for: toVC)
        let tfinalFrame = transitionContext.finalFrame(for: toVC)
        
        let framesInfo = FJCustomPresentationContext.TransitionContextFrames.init(fromInitialFrame: finitialFrame, fromFinalFrame: ffinalFrame, toInitialFrame: tinitialFrame, toFinalFrame: tfinalFrame)
        
        if isPresenting {
            cv.addSubview(toView)
        }
        let t  = transitionDuration(using: transitionContext)
        if isPresenting {
            context.transitionAnimator?(fromView, toView, .present(frames: framesInfo), t, transitionContext)
        } else {
            context.transitionAnimator?(fromView, toView, .dismiss(frames: framesInfo), t, transitionContext)
        }
    }
}


// MARK: - FJCustomAlertPresentationContext
/// 弹窗驱动上下文
@MainActor final public class FJCustomPresentationContext: @unchecked Sendable {
    init() {
        `default` = FJCustomPresentationContext.Default()
        frameOfPresentedViewInContainerView = `default`.centerFrameOfPresentedView
        presentationWrappingView = `default`.shadowAllRoundedCornerWrappingView(10)
        belowCoverView = `default`.dimmingBelowCoverView
        transitionAnimator = `default`.centerTransitionAnimator
        willPresentAnimatorForBelowCoverView = `default`.dimmingBelowCoverViewAnimator(true)
        willDismissAnimatorForBelowCoverView = `default`.dimmingBelowCoverViewAnimator(false)
    }
    
    /// 默认配置
    public let `default`: FJCustomPresentationContext.Default
    
    /// 转场动画持续时间---默认0.25s
    public var duration: TimeInterval = 0.25
    
    /// 源控制器是否触发生命周期(viewWillDisappear/viewDidDisappear/viewWillAppear/viewDidAppear),默认不触发任何
    public var presentingControllerTriggerAppearLifecycle = TriggerPresentingControllerLifecycle.none
    
    /// 弹出界面的其余部分点击事件,默认为自动dismiss
    ///
    /// 可以在弹窗出现之后通过`AlertPresentationController`的`updateContext`方法随时更改此属性
    ///
    /// eg:可以在弹窗展示的时候为`.autodismiss(false)`,然后,在页面事件处理完成之后改为`.autodismiss(true)`
    ///
    /// 同时,默认的点击空白消失是带动画的.如果不想带动画,请设置为`.customize`,在block内部手动调用dismiss
    public var belowCoverAction = FJCustomPresentationContext.BelowCoverAction.autodismiss(true)
    
    /// preferredContentSize 改变时的动画配置, 默认为nil
    public var preferredContentSizeDidChangeAnimationInfo: (duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions)?
    
    /// 转场动画中presentingViewController的View的frame----默认frame可以使presentingView居中
    public var frameOfPresentedViewInContainerView: (@MainActor @Sendable (_ containerViewBounds: CGRect, _ preferredContentSize: CGSize) -> (CGRect))?
    
    /// presentingViewController的view修饰view----默认4个圆角带阴影view
    public var presentationWrappingView: (@MainActor @Sendable (_ presentedViewControllerView: UIView, _ frameOfPresentedView: CGRect) -> UIView)?
    
    /// presentingViewController的view底部封面view,默认是暗灰色view
    ///
    /// 一般是暗灰色的view或者UIVisualEffectView,同时将autoresizingMask设置成[.flexibleWidth, .flexibleHeight];
    ///
    ///  在转场动画时,可以做动画效果
    /// - 例如:UIVisualEffectView可以在presentationTransitionWillBegin动画时间里,将effect从nil,设置成UIBlurEffect(style: .extraLight)
    ///       并在dismissalTransitionWillBegin动画时间里,将effect设置成nil
    /// - 暗灰色的view:可以在presentationTransitionWillBegin动画时间里,将alpha从0.0,设置成0.5
    ///       并在dismissalTransitionWillBegin动画时间里,将alpha设置成0.0
    public var belowCoverView: (@MainActor @Sendable (_ frame: CGRect) -> UIView)?
    
    /// 转场动画的具体实现----默认是弹出居中view的动画效果
    public var transitionAnimator: (@MainActor @Sendable (_ fromView: UIView, _ toView: UIView, _ style: FJCustomPresentationContext.TransitionType, _ duration: TimeInterval, _ ctx: UIViewControllerContextTransitioning) -> ())?
    
    /// 转场动画presentationTransitionWillBegin时,belowCoverView要展示的动画效果,默认是暗灰色view的动画效果
    ///
    /// 例如:
    ///
    ///     context.belowCorverBeginPresentAnimator = { view, coordinator in
    ///          guard let blurView = view as? UIVisualEffectView else { return }
    ///          coordinator.animate(alongsideTransition: { _ in
    ///             blurView.effect = UIBlurEffect(style: .extraLight)
    ///         }, completion: nil)
    ///     }
    ///
    public var willPresentAnimatorForBelowCoverView: ((_ belowCoverView: UIView, _ coordinator: UIViewControllerTransitionCoordinator) -> ())?
    
    /// 转场动画dismissalTransitionWillBegin时,belowCoverView要展示的动画效果,默认是暗灰色view的动画效果
    ///
    /// 例如:
    ///
    ///     context.belowCorverBeginPresentAnimator = { view, coordinator in
    ///          guard let blurView = view as? UIVisualEffectView else { return }
    ///          coordinator.animate(alongsideTransition: { _ in
    ///             blurView.effect = nil
    ///         }, completion: nil)
    ///     }
    ///
    public var willDismissAnimatorForBelowCoverView: ((_ belowCoverView: UIView, _ coordinator: UIViewControllerTransitionCoordinator) -> ())?
}

extension FJCustomPresentationContext {
    /// 使用一套居中弹出动画
    @MainActor public func usingCenterPresentation() {
        transitionAnimator = `default`.centerTransitionAnimator
        frameOfPresentedViewInContainerView = `default`.centerFrameOfPresentedView
    }
    
    /// 使用一套从底部弹出动画
    @MainActor public func usingBottomPresentation() {
        transitionAnimator = `default`.bottomTransitionAnimator
        frameOfPresentedViewInContainerView = `default`.bottomFrameOfPresentedView
    }
    
    /// 使用一套clear view的显示/隐藏动画
    @MainActor public func usingClearCoverAnimators() {
        belowCoverView = `default`.clearBelowCoverView
        willPresentAnimatorForBelowCoverView = `default`.clearBelowCoverViewAnimator(true)
        willDismissAnimatorForBelowCoverView = `default`.clearBelowCoverViewAnimator(false)
    }
    
    /// 使用一套暗灰色 view的显示/隐藏动画
    @MainActor public func usingDimmingBelowCoverAnimators() {
        belowCoverView = `default`.dimmingBelowCoverView
        willPresentAnimatorForBelowCoverView = `default`.dimmingBelowCoverViewAnimator(true)
        willDismissAnimatorForBelowCoverView = `default`.dimmingBelowCoverViewAnimator(false)
    }
    
    /// 使用一套高斯模糊的显示/隐藏动画
    @MainActor public func usingBlurBelowCoverAnimators(style: UIBlurEffect.Style) {
        belowCoverView = `default`.blurBelowCoverView
        willPresentAnimatorForBelowCoverView = `default`.blurBelowCoverViewAnimator(style)(true)
        willDismissAnimatorForBelowCoverView = `default`.blurBelowCoverViewAnimator(style)(false)
    }
}

extension FJCustomPresentationContext {
    /// 转场动画的过渡类型
    public enum TransitionType {
        case present(frames: TransitionContextFrames)
        case dismiss(frames: TransitionContextFrames)
    }
    
    /// 转场动画过程中的frame
    public struct TransitionContextFrames: Sendable {
        public let fromInitialFrame: CGRect
        public let fromFinalFrame: CGRect
        public let toInitialFrame: CGRect
        public let toFinalFrame: CGRect
    }
    
    /// 点击弹出界面的其余部分事件
    public enum BelowCoverAction {
        /// 是否自动dismiss
        case autodismiss(_ auto: Bool)
        /// 自定义动作
        case customize(action: () -> ())
    }
    
    
    /// 源控制器触发生命周期
    public struct TriggerPresentingControllerLifecycle: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        /// 不触发任何生命周期
        public static var none: TriggerPresentingControllerLifecycle {
            return TriggerPresentingControllerLifecycle(rawValue: 1 << 0)
        }
        
        /// 触发viewWillDisappear+viewDidDisappear
        public static var disappear: TriggerPresentingControllerLifecycle {
            return TriggerPresentingControllerLifecycle(rawValue: 1 << 1)
        }
        
        /// 触发viewWillAppear+viewDidAppear
        public static var appear: TriggerPresentingControllerLifecycle {
            return TriggerPresentingControllerLifecycle(rawValue: 1 << 2)
        }

        /// 触发所有
        public static var all: TriggerPresentingControllerLifecycle {
            let rvalue = TriggerPresentingControllerLifecycle.disappear.rawValue |
                           TriggerPresentingControllerLifecycle.appear.rawValue
            return TriggerPresentingControllerLifecycle(rawValue: rvalue)
        }
    }
}


// MARK: - FJCustomAlertPresentationContext Default
extension FJCustomPresentationContext {
    /// 提供GenericPresentationContext的一些基本默认设置
    public struct Default: @unchecked Sendable {
        /// 转场动画时,高斯模糊view作为presentedViewController view的背景
        public private(set) var blurBelowCoverView: @MainActor (CGRect) -> UIView = { f in
            let v = UIVisualEffectView(frame: f)
            v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            v.effect = nil
            return v
        }
        
        /// 转场动画present/dismiss时,高斯模糊view的动画效果
        public private(set) var blurBelowCoverViewAnimator: @MainActor (UIBlurEffect.Style) -> (Bool) -> ((UIView, UIViewControllerTransitionCoordinator) -> ()) = { style in
            return { isPresenting in
                return { view, coor in
                    guard let bv = view as? UIVisualEffectView else { return }
                    coor.animate(alongsideTransition: { _ in
                        bv.effect = isPresenting ? UIBlurEffect(style: style) : nil
                    }, completion: nil)
                }
            }
        }
        
        /// 转场动画时,暗灰色view作为presentedViewController view的背景
        public private(set) var dimmingBelowCoverView: @MainActor (CGRect) -> UIView = { f in
            let v = UIView(frame: f)
            v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            v.backgroundColor = .black
            v.isOpaque = false
            return v
        }
        
        /// 转场动画present/dismiss时,暗灰色view的动画效果
        public private(set) var dimmingBelowCoverViewAnimator: @MainActor (Bool) -> ((UIView, UIViewControllerTransitionCoordinator) -> ()) = { isPresenting in
            return { view, coor in
                if isPresenting {
                    view.alpha = 0
                }
                coor.animate(alongsideTransition: { _ in
                    view.alpha = isPresenting ? 0.5 : 0.0
                }, completion: nil)
            }
        }
        
        /// 转场动画时,clear view作为presentedViewController view的背景
        public private(set) var clearBelowCoverView: @MainActor (CGRect) -> UIView = { f in
            let v = UIView(frame: f)
            v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            v.backgroundColor = .clear
            return v
        }
        
        /// 转场动画present/dismiss时,clear色view的动画效果
        public private(set) var clearBelowCoverViewAnimator: @MainActor @Sendable (Bool) -> ((UIView, UIViewControllerTransitionCoordinator) -> ()) = { isPresenting in
            return { _, _ in}
        }
        
        /// 上部圆角圆角带阴影的presentedViewController view修饰view
        public private(set) var shadowTopRoundedCornerWrappingView: @MainActor @Sendable (CGFloat) -> @MainActor @Sendable (UIView, CGRect) -> (UIView) = { radius in
            return { presentedViewControllerView, frame in
                let presentationWrapperView = UIView(frame: frame)
                presentationWrapperView.layer.shadowOpacity = 0.44
                presentationWrapperView.layer.shadowRadius = 13
                presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: -6)
                
                let presentationRoundedCornerView = UIView(frame: presentationWrapperView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -radius, right: 0)))
                presentationRoundedCornerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                presentationRoundedCornerView.layer.cornerRadius = radius
                presentationRoundedCornerView.layer.masksToBounds = true
                
                let presentedViewControllerWrapperView = UIView(frame: presentationRoundedCornerView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: radius, right: 0)))
                presentedViewControllerWrapperView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                
                presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
                presentedViewControllerWrapperView.addSubview(presentedViewControllerView)

                presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
                
                presentationWrapperView.addSubview(presentationRoundedCornerView)
                
                return presentationWrapperView
            }
        }
        
        /// 4个圆角带阴影的presentedViewController view修饰view
        public private(set) var shadowAllRoundedCornerWrappingView: @MainActor @Sendable (CGFloat) -> @MainActor @Sendable (UIView, CGRect) -> (UIView) = { radius in
            return { presentedViewControllerView, frame in
                let presentationWrapperView = UIView(frame: frame)
                presentationWrapperView.layer.shadowOpacity = 0.44
                presentationWrapperView.layer.shadowRadius = 13
                presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: -6)
                let presentationRoundedCornerView = UIView(frame: presentationWrapperView.bounds)
                presentationRoundedCornerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                presentationRoundedCornerView.layer.cornerRadius = radius
                presentationRoundedCornerView.layer.masksToBounds = true
                
                presentedViewControllerView.frame = presentationRoundedCornerView.bounds
                
                presentationRoundedCornerView.addSubview(presentedViewControllerView)
                
                presentationWrapperView.addSubview(presentationRoundedCornerView)
                
                return presentationWrapperView
            }
        }
        
        /// 4个圆角不带阴影的presentedViewController view修饰view
        public private(set) var allRoundedCornerWrappingView: @MainActor @Sendable (CGFloat) -> @MainActor @Sendable (UIView, CGRect) -> (UIView) = { radius in
            return { presentedViewControllerView, frame in
                    let presentationRoundedCornerView = UIView(frame: frame)
                    presentationRoundedCornerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    presentationRoundedCornerView.layer.cornerRadius = radius
                    presentationRoundedCornerView.layer.masksToBounds = true
                    
                    presentedViewControllerView.frame = presentationRoundedCornerView.bounds
                    
                    presentationRoundedCornerView.addSubview(presentedViewControllerView)
                    
                    return presentationRoundedCornerView
            }
        }
        
        /// 上部圆角圆角不带阴影的presentedViewController view修饰view
        public private(set) var topRoundedCornerWrappingView: @MainActor @Sendable (CGFloat) -> @MainActor @Sendable (UIView, CGRect) -> (UIView) = { radius in
            return { presentedViewControllerView, frame in
                let presentationRoundedCornerView = UIView(frame: frame)
                presentationRoundedCornerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                presentationRoundedCornerView.layer.cornerRadius = radius
                presentationRoundedCornerView.layer.masksToBounds = true
                presentationRoundedCornerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                presentedViewControllerView.frame = presentationRoundedCornerView.bounds
                presentationRoundedCornerView.addSubview(presentedViewControllerView)
                return presentationRoundedCornerView
            }
        }
        
        /// 无效果的presentedViewController view修饰view
        public private(set) var emptyWrappingView: @MainActor (UIView, CGRect) -> (UIView) = { presentedViewControllerView, frame in
            let presentationWrapperView = UIView(frame: frame)
            presentedViewControllerView.frame = presentationWrapperView.bounds
            presentationWrapperView.addSubview(presentedViewControllerView)
            return presentationWrapperView
        }
        
        /// 使presentedViewController的view居中显示的frame
        public private(set) var centerFrameOfPresentedView: @MainActor @Sendable (CGRect, CGSize) -> (CGRect) = {
            bounds, size in
            let x = (bounds.width - size.width) * 0.5
            let y = (bounds.height - size.height) * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: size)
        }
        
        /// 使presentedViewController的view在底部显示的frame
        public private(set) var bottomFrameOfPresentedView: @MainActor (CGRect, CGSize) -> (CGRect) = {
            bounds, size in
            let x = bounds.midX - size.width * 0.5
            let y = bounds.maxY - size.height
            return CGRect(origin: CGPoint(x: x, y: y), size: size)
        }
        
        /// 居中弹出presentedViewController的动画效果
        public private(set) var centerTransitionAnimator: @MainActor (UIView, UIView, FJCustomPresentationContext.TransitionType, TimeInterval, UIViewControllerContextTransitioning) -> () = { fromView, toView, style, duration, ctx in
            switch style {
            case .present(frames: let frames):
                toView.frame = frames.toFinalFrame
                toView.transform = toView.transform.scaledBy(x: 0.5, y: 0.5)
                if #available(iOS 17.0, *) {
                    UIView.animate(springDuration: duration, bounce: 0.5, initialSpringVelocity: 10, options: .curveEaseInOut) {
                        toView.transform = CGAffineTransform.identity
                    } completion: { _ in
                        let wasCancelled = ctx.transitionWasCancelled
                        ctx.completeTransition(!wasCancelled)
                    }
                } else {
                    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveEaseInOut) {
                        toView.transform = CGAffineTransform.identity
                    } completion: { _ in
                        let wasCancelled = ctx.transitionWasCancelled
                        ctx.completeTransition(!wasCancelled)
                    }
                }
            case .dismiss(frames: let frames):
                fromView.frame = frames.fromInitialFrame
                fromView.transform = CGAffineTransform.identity
                UIView.animate(withDuration: duration, animations: {
                    fromView.transform = fromView.transform.scaledBy(x: 0.5, y: 0.5)
                    fromView.alpha = 0.2
                }, completion: { _ in
                    let wasCancelled = ctx.transitionWasCancelled
                    ctx.completeTransition(!wasCancelled)
                })
            }
        }
        
        /// 从底部弹出presentedViewController的动画效果
        public private(set) var bottomTransitionAnimator: @MainActor (UIView, UIView, FJCustomPresentationContext.TransitionType, TimeInterval, UIViewControllerContextTransitioning) -> () = { fromView, toView, style, duration, ctx in
            switch style {
            case .present(frames: let frames):
                let f = frames.toFinalFrame
                toView.frame = f.offsetBy(dx: 0, dy: f.height)
                if #available(iOS 17.0, *) {
                    UIView.animate(springDuration: duration, bounce: 0.33, initialSpringVelocity: 10, options: .curveEaseInOut) {
                        toView.frame = frames.toFinalFrame
                    } completion: { _ in
                        let wasCancelled = ctx.transitionWasCancelled
                        ctx.completeTransition(!wasCancelled)
                    }
                } else {
                    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.77, initialSpringVelocity: 10, options: .curveEaseInOut) {
                        toView.frame = frames.toFinalFrame
                    } completion: { _ in
                        let wasCancelled = ctx.transitionWasCancelled
                        ctx.completeTransition(!wasCancelled)
                    }
                }
            case .dismiss(frames: let frames):
                let f = frames.fromInitialFrame
                fromView.frame = f
                UIView.animate(withDuration: duration, animations: {
                    let f = frames.fromInitialFrame
                    fromView.frame = f.offsetBy(dx: 0, dy: f.height)
                }) { _ in
                    let wasCancelled = ctx.transitionWasCancelled
                    ctx.completeTransition(!wasCancelled)
                }
            }
        }
    }
}
