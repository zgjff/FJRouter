//
//  SystemPushAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/12.
//

import Foundation
import UIKit

extension FJRoute {
    /// 使用系统push进行显示
    ///
    ///
    /// 若要使用自定义转场动画, 请在`toVC`内部自行设置`navigationController?.delegate = xxx`
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
