//
//  RefreshSamePreviousAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

extension FJRoute {
    /// 刷新与匹配控制器相同类型的上一个控制器动画
    ///
    /// 一般用于, 当匹配到的路由指向控制器, 与app最上层正在展示的控制器是同一类, 按照设计要求,
    /// 此时不需要跳转新的页面, 而是需要更新正在展示的控制器内容. eg:
    ///
    ///     try await FJRouter.shared.registerRoute(FJRoute(path: "/four", name: "four", builder: { sourceController, state in
    ///         FourViewController()
    ///     }, animator: { info in
    ///         if let pvc = info.fromVC, pvc is FourViewController { // 或者其它判断条件
    ///             return FJRoute.RefreshSamePreviousAnimator { @Sendable previousVC, state in
    ///                 previousVC.view.backgroundColor = .random()
    ///             }
    ///         }
    ///         return FJRoute.SystemPushAnimator()
    ///     }))
    ///
    public struct RefreshSamePreviousAnimator: FJRouteAnimator {
        private let refresh: @MainActor @Sendable (_ previousVC: UIViewController, _ state: FJRouterState) -> ()
        public init(refresh: @MainActor @Sendable @escaping (_ previousVC: UIViewController, _ state: FJRouterState) -> ()) {
            self.refresh = refresh
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            if let fromVC {
                refresh(fromVC, matchState)
            }
        }
    }
}
