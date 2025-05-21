//
//  FJRouterJumpCore.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

#if canImport(UIKit)
import UIKit
import Foundation
import Combine

extension FJRouter {
    internal final class JumpCore: @unchecked Sendable {
        var errorBuilder: (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)
        var apptopController: (@MainActor (_ current: UIViewController?) -> UIViewController?)
        init() {
            errorBuilder = { @MainActor @Sendable state in
                return FJRouterErrorController(state: state)
            }
            apptopController = { @MainActor @Sendable current in
                UIApplication.shared.fj.topViewController(current)
            }
        }
    }
}

extension FJRouter.JumpCore {
    @MainActor func viewController(for matchList: FJRouteMatchList) -> UIViewController? {
        guard let match = matchList.lastMatch else {
            return nil
        }
        let state = FJRouterState(matches: matchList, match: match)
        let tvc = apptopController(UIApplication.shared.fj.versionkKeyWindow?.rootViewController)
        return match.route.builder?(FJRoute.BuilderInfo(fromVC: tvc, matchState: state))
    }
    
    @MainActor func go(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool, callback: FJRouterCallbackable) throws(FJRouter.JumpMatchError) {
        switch matchList.result {
        case .error:
            if ignoreError {
                throw FJRouter.JumpMatchError.notFind
            }
            goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
            return
        case .success:
            guard let match = matchList.lastMatch else {
                if ignoreError {
                    throw FJRouter.JumpMatchError.notFind
                }
                goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
                return
            }
            let state = FJRouterState(matches: matchList, match: match)
            guard let route = state.route else {
                if ignoreError {
                    throw FJRouter.JumpMatchError.notFind
                }
                goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
                return
            }
            guard route.builder != nil else {
                if ignoreError {
                    throw FJRouter.JumpMatchError.noBuilder
                }
                goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
                return
            }
            let fromController = sourceController ?? apptopController(UIApplication.shared.fj.versionkKeyWindow?.rootViewController)
            let animator = route.animator(FJRoute.AnimatorInfo(fromVC: fromController, matchState: state))
            animator.startAnimated(from: fromController, to: { [fromController] in
                let vc = route.builder!(FJRoute.BuilderInfo(fromVC: fromController, matchState: state))
                vc.fj.addCallbackTrigger(callback: callback)
                return vc
            }, state: state)
        }
    }
    
    @MainActor func goError(state: FJRouterState, sourceController: UIViewController?) {
        let errorController = errorBuilder(state)
        private_go(to: errorController, from: sourceController, animated: true, isError: true)
    }
    
    @MainActor private func private_go(to destController: UIViewController, from sourceController: UIViewController?, animated flag: Bool, isError: Bool) {
        let fromController = sourceController ?? apptopController(UIApplication.shared.fj.versionkKeyWindow?.rootViewController)
        guard let fromController else {
            // FIXME: 是否需要这样做
            UIApplication.shared.fj.versionkKeyWindow?.rootViewController = destController
            return
        }
        if let navi = fromController.navigationController {
            destController.hidesBottomBarWhenPushed = true
            navi.pushViewController(destController, animated: flag)
            return
        }
        if isError {
            let navi = UINavigationController(rootViewController: destController)
            fromController.present(navi, animated: flag)
            return
        }
        fromController.present(destController, animated: flag)
    }
}

#endif
