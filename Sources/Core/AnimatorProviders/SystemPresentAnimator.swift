//
//  SystemPresentAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

extension FJRoute {
    /// 使用系统present动画进行显示
    public struct SystemPresentAnimator: FJRouteAnimator {
        private let useNavigationController: UINavigationController?
        private let fullScreen: Bool
        
        /// 初始化
        /// - Parameters:
        ///   - fullScreen: 是否设置`modalPresentationStyle`为`fullScreen`
        ///   - useNavigationController: 使用导航栏包裹控制器. 注意navigationController必须是新初始化生成的
        public init(fullScreen: Bool = false, navigationController useNavigationController: UINavigationController? = nil) {
            self.fullScreen = fullScreen
            self.useNavigationController = useNavigationController
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            var destVC = toVC
            if let useNavigationController {
                useNavigationController.setViewControllers([toVC], animated: false)
                destVC = useNavigationController
            }
            destVC.transitioningDelegate = nil
            if fullScreen {
                destVC.modalPresentationStyle = .fullScreen
            }
            fromVC?.present(destVC, animated: true)
        }
    }
}
