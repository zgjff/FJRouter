//
//  AppRootControllerAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

extension FJRoute {
    /// 设置app window的rootViewController
    public struct AppRootControllerAnimator: FJRouteAnimator {
        private let useNavigationController: UINavigationController?
        public init(navigationController useNavigationController: UINavigationController? = nil) {
            self.useNavigationController = useNavigationController
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            if let useNavigationController {
                useNavigationController.setViewControllers([toVC], animated: false)
                UIApplication.shared.versionkKeyWindow?.rootViewController = useNavigationController
            } else {
                UIApplication.shared.versionkKeyWindow?.rootViewController = toVC
            }
        }
    }
}
