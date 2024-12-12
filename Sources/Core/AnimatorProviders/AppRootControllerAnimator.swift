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
        public init() {}
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            UIApplication.shared.versionkKeyWindow?.rootViewController = toVC
        }
    }
}
