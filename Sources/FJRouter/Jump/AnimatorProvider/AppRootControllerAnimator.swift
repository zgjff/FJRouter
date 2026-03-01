//
//  AppRootControllerAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/14.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
extension FJRouteAnimatorProviders {
    /// 设置app window的rootViewController
    public struct AppRootController: FJRouteTargetAnimatorProvider {
        private let useNavigationController: UINavigationController?
        public init(navigationController useNavigationController: UINavigationController? = nil) {
            self.useNavigationController = useNavigationController
        }
    }
}
#endif
