//
//  FJRouterCore.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
import UIKit

final class FJRouterCore: @unchecked Sendable {
    var errorBuilder: FJRoute.PageBuilder
    var apptopController: (@MainActor (_ current: UIViewController?) -> UIViewController?)
    init() {
        errorBuilder = { state in
            return FJRouterErrorController(state: state)
        }
        apptopController = { current in
            UIApplication.shared.topViewController(current)
        }
    }
}

extension FJRouterCore {
    @MainActor func viewController(for matchList: FJRouteMatchList, ignoreError: Bool) -> UIViewController? {
        guard let match = matchList.lastMatch else {
            if ignoreError {
                return nil
            }
            let state = FJRouterState(matches: matchList)
            let viewController = errorBuilder(state)
            return viewController
        }
        let state = FJRouterState(matches: matchList, match: match)
        let viewController = match.route.builder?(state)
        return viewController
    }
    
    @MainActor func go(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) {
        switch matchList.result {
        case .error:
            if ignoreError {
                return
            }
            let state = FJRouterState(matches: matchList)
            let viewController = errorBuilder(state)
            private_go(to: viewController, from: sourceController, animated: true, isError: true)
        case .success:
            guard let match = matchList.lastMatch else {
                if ignoreError {
                    return
                }
                let state = FJRouterState(matches: matchList)
                let viewController = errorBuilder(state)
                private_go(to: viewController, from: sourceController, animated: true, isError: true)
                return
            }
            let state = FJRouterState(matches: matchList, match: match)
            guard let viewController = match.route.builder?(state) else {
                let state = FJRouterState(matches: matchList)
                let viewController = errorBuilder(state)
                private_go(to: viewController, from: sourceController, animated: true, isError: true)
                return
            }
            if match.route.displayAction != nil {
                let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
                match.route.displayAction?(fromController, viewController, state)
                return
            }
            private_go(to: viewController, from: sourceController, animated: flag, isError: false)
        }
    }
    
    @MainActor func private_go(to destController: UIViewController, from sourceController: UIViewController?, animated flag: Bool, isError: Bool) {
        let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
        guard let fromController else {
            // FIXME: 是否需要这样做
            UIApplication.shared.versionkKeyWindow?.rootViewController = sourceController
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
    
    @MainActor func push(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) {
        guard let viewController = viewController(for: matchList, ignoreError: ignoreError)else {
            return
        }
        let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
        guard let fromController else {
            return
        }
        fromController.navigationController?.pushViewController(viewController, animated: flag)
    }
    
    @MainActor func present(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) {
        guard let viewController = viewController(for: matchList, ignoreError: ignoreError) else {
            return
        }
        let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
        guard let fromController else {
            return
        }
        viewController.modalPresentationStyle = .fullScreen
        fromController.present(viewController, animated: flag)
    }
}
