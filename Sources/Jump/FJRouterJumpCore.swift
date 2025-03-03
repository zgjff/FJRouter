//
//  FJRouterJumpCore.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
import Combine
#if canImport(UIKit)
import UIKit

extension FJRouter {
    internal final class JumpCore: @unchecked Sendable {
        var errorBuilder: (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)
        var apptopController: (@MainActor (_ current: UIViewController?) -> UIViewController?)
        init() {
            errorBuilder = { @MainActor @Sendable state in
                return FJRouterErrorController(state: state)
            }
            apptopController = { @MainActor @Sendable current in
                UIApplication.shared.topViewController(current)
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
        let tvc = apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
        return match.route.builder?(FJRoute.BuilderInfo(fromVC: tvc, matchState: state))
    }
    
    @discardableResult
    @MainActor func go(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) -> UIViewController? {
        switch matchList.result {
        case .error:
            if ignoreError {
                return nil
            }
            goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
            return nil
        case .success:
            guard let match = matchList.lastMatch else {
                if ignoreError {
                    return nil
                }
                goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
                return nil
            }
            let state = FJRouterState(matches: matchList, match: match)
            guard let route = state.route else {
                if ignoreError {
                    return nil
                }
                goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
                return nil
            }
            let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
            guard let tovc = route.builder?(FJRoute.BuilderInfo(fromVC: fromController, matchState: state)) else {
                return nil
            }
            let animator = route.animator(FJRoute.AnimatorInfo(fromVC: fromController, toVC: tovc, matchState: state))
            animator.startAnimatedTransitioning(from: fromController, to: tovc, state: state)
            return tovc
        }
    }
    
    @MainActor func goError(state: FJRouterState, sourceController: UIViewController?) {
        let errorController = errorBuilder(state)
        private_go(to: errorController, from: sourceController, animated: true, isError: true)
    }
    
    @MainActor private func private_go(to destController: UIViewController, from sourceController: UIViewController?, animated flag: Bool, isError: Bool) {
        let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
        guard let fromController else {
            // FIXME: 是否需要这样做
            UIApplication.shared.versionkKeyWindow?.rootViewController = destController
            return
        }
        if let navi = fromController.navigationController {
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
