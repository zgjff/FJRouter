//
//  AppRootControllerAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension FJRoute {
    /// 设置app window的rootViewController
    public struct AppRootControllerAnimator: FJRouteAnimator {
        private let useNavigationController: UINavigationController?
        public init(navigationController useNavigationController: UINavigationController? = nil) {
            self.useNavigationController = useNavigationController
        }
        
        public func startAnimated(from fromVC: UIViewController?, to toVC: @escaping @MainActor () -> UIViewController, state matchState: FJRouterState) {
            let tvc = toVC()
            var destVC = tvc
            if let useNavigationController {
                useNavigationController.setViewControllers([tvc], animated: false)
                destVC = useNavigationController
            }
            UIApplication.shared.fj.versionkKeyWindow?.rootViewController = destVC
        }
    }
}

#endif
