//
//  FJRouteTargetAnimator.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

extension FJRouteTarget {
    /// 显示路由指向控制器的转场动画
    ///
    /// 框架内部提供了多种内置实现: FJRoute.XXXXAnimator
    public struct Animator: @unchecked Sendable {
        private let animator: @MainActor @Sendable (_ info: AnimatorInfo) -> any FJRouteAnimator
        public init(_ animator: @MainActor @Sendable @escaping (_ info: AnimatorInfo) -> any FJRouteAnimator) {
            self.animator = animator
        }
    }
}
