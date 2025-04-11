//
//  PushAnimatorConfig.swift
//  FJRouter
//
//  Created by zgjff on 2025/4/11.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension FJRoute {
    /// push配置
    public struct PushAnimatorConfig: Sendable {
        let hidesBottomBarWhenPushed: Bool
        let ptedAction: NaviPresentedAction

        /// 初始化
        /// - Parameters:
        ///   - hidesBottomBar: 设置push时`hidesBottomBarWhenPushed`
        ///   - ptedAction: 当检查到`navigationController`存在`presentedViewController`,
        ///   即已经`present`出新的控制器时的行为
        public init(
            hidesBottomBar: Bool = true,
            ptedAction: NaviPresentedAction = .push
        ) {
            self.hidesBottomBarWhenPushed = hidesBottomBar
            self.ptedAction = ptedAction
        }
    }
}

extension FJRoute.PushAnimatorConfig {
    /// 当检查到`navigationController`存在`presentedViewController`,
    /// 即已经`present`出新的控制器时的行为
    public enum NaviPresentedAction: @unchecked Sendable {
        public typealias StartPush = @MainActor @Sendable () -> ()
        
        /// 直接`push`, 无需将已经存在的`presentedViewController`控制器`dismiss`,
        /// push动画之后, `presentedViewController`仍然存在, 且仍然在上层
        case push
        
        /// 将已经存在的`presentedViewController`控制器`dismiss`之后再`push`
        case dismiss(animated: Bool)
        
        /// 不做任何动作: 不`push`, 也不`dismiss`再`push`
        case none
        
        /// 自定义动作. 使用于特殊的需求, eg:
        ///
        ///     await FJRouter.jump().registerRoute(try FJRoute(path: "/second", name: "second", builder: { _ in    SecondViewController() }, animator: { _ in
        ///         FJRoute.SystemPushAnimator(config: FJRoute.PushAnimatorConfig.init(ptedAction: .custom(action: { ptedvc, start in
        ///             let alertvc = UIAlertController(title: "已有弹窗", message: "确定push吗?", preferredStyle: .alert)
        ///             let ok = UIAlertAction(title: "确定", style: .default) { [weak ptedvc] _ in
        ///                 ptedvc?.dismiss(animated: true) {
        ///                     push()
        ///                 }
        ///             }
        ///             let cancel = UIAlertAction(title: "取消", style: .cancel)
        ///             alertvc.addAction(ok)
        ///             alertvc.addAction(cancel)
        ///             ptedvc.present(alertvc, animated: true)
        ///         })))
        ///     }))
        case custom(action: @MainActor @Sendable (_ ptedvc: UIViewController, _ push: @escaping StartPush) -> ())
    }
}

#endif
