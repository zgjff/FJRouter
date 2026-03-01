//
//  AutomaticAnimator.swift
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
    /// 根据情况自动选择动画方式
    ///
    /// 如果有`fromVC`且有导航栏, 则进行系统`push`
    ///
    /// 如果有`fromVC`且没有导航栏, 则进行系统`present`
    ///
    /// 如果没有`fromVC`,判定`window`没有`rootController`, 则设置`rootController`
    public struct AutomaticAnimator: FJRouteTargetAnimatorProvider {
        private let useNavigationController: UINavigationController?
        /// 初始化方法
        /// - Parameter useNavigationController: 在进行`preesnt`和`rootController`时, 是否需要导航栏包裹控制器.
        ///  在判断为`push`时, 此参数无效; 注意navigationController必须是新初始化生成的
        public init(navigationController useNavigationController: UINavigationController? = nil) {
            self.useNavigationController = useNavigationController
        }
    }
}
#endif
