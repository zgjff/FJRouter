//
//  SystemPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

extension FJRoute {
    /// 使用系统push动画进行显示
    public struct SystemPushAnimator: FJRouteAnimator {
        private let hidesBottomBarWhenPushed: Bool
        public init(hidesBottomBarWhenPushed: Bool = true) {
            self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        }
        
        public func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState) {
            toVC.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
            fromVC?.navigationController?.pushViewController(toVC, animated: true)
        }
    }
}
