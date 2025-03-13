//
//  AutomaticAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/28.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension FJRoute {
    /// 根据情况自动选择动画方式
    ///
    /// 如果有`fromVC`且有导航栏, 则进行系统`push`
    ///
    /// 如果有`fromVC`且没有导航栏, 则进行系统`present`
    ///
    /// 如果没有`fromVC`,判定`window`没有`rootController`, 则设置`rootController`
    public struct AutomaticAnimator: FJRouteAnimator {
        private let useNavigationController: UINavigationController?
        /// 初始化方法
        /// - Parameter useNavigationController: 在进行`preesnt`和`rootController`时, 是否需要导航栏包裹控制器.
        ///  在判断为`push`时, 此参数无效; 注意navigationController必须是新初始化生成的
        public init(navigationController useNavigationController: UINavigationController? = nil) {
            self.useNavigationController = useNavigationController
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            guard let fromVC else {
                let ar = AppRootControllerAnimator(navigationController: useNavigationController)
                ar.startAnimatedTransitioning(from: fromVC, to: toVC, state: matchState)
                return
            }
            if fromVC.navigationController != nil {
                let pp = SystemPushAnimator(hidesBottomBarWhenPushed: true)
                pp.startAnimatedTransitioning(from: fromVC, to: toVC, state: matchState)
                return
            }
            let sp = SystemPresentAnimator(navigationController: useNavigationController)
            return sp.startAnimatedTransitioning(from: fromVC, to: toVC, state: matchState)
        }
    }
}

#endif
