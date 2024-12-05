//
//  FJRouterCore.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation
import UIKit

final class FJRouterCore: @unchecked Sendable {
    var errorBuilder: (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)
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
    @MainActor func viewController(for matchList: FJRouteMatchList) -> UIViewController? {
        guard let match = matchList.lastMatch else {
            return nil
        }
        let state = FJRouterState(matches: matchList, match: match)
        switch match.route.builder {
        case .default(let action):
            let vc = action(state)
            return vc
        case .display(let action):
            let tvc = apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
            let vc = action(tvc, state)
            return vc
        case .none:
            return nil
        }
    }
    
    @MainActor func go(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) {
        switch matchList.result {
        case .error:
            if ignoreError {
                return
            }
            goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
        case .success:
            guard let match = matchList.lastMatch else {
                if ignoreError {
                    return
                }
                goError(state: FJRouterState(matches: matchList), sourceController: sourceController)
                return
            }
            let state = FJRouterState(matches: matchList, match: match)
            
            switch match.route.builder {
            case .default(let action):
                let destController = action(state)
                private_go(to: destController, from: sourceController, animated: flag, isError: false)
            case .display(let action):
                let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
                _ = action(fromController, state)
            case .none:
                return
            }
        }
    }
    
    @MainActor func push(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) {
        switch matchList.result {
        case .error:
            if ignoreError {
                return
            }
            let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
            let state = FJRouterState(matches: matchList)
            fromController?.navigationController?.pushViewController(errorBuilder(state), animated: flag)
        case .success:
            guard let match = matchList.lastMatch else {
                if ignoreError {
                    return
                }
                let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
                let state = FJRouterState(matches: matchList)
                fromController?.navigationController?.pushViewController(errorBuilder(state), animated: flag)
                return
            }
            let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
            let state = FJRouterState(matches: matchList, match: match)
            switch match.route.builder {
            case .default(let action):
                let destController = action(state)
                fromController?.navigationController?.pushViewController(destController, animated: flag)
            case .display(let action):
                _ = action(fromController, state)
            case .none:
                return
            }
        }
    }
    
    @MainActor func present(matchList: FJRouteMatchList, sourceController: UIViewController?, ignoreError: Bool, animated flag: Bool) {
        switch matchList.result {
        case .error:
            if ignoreError {
                return
            }
            let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
            let state = FJRouterState(matches: matchList)
            let errvc = errorBuilder(state)
            errvc.modalPresentationStyle = .fullScreen
            fromController?.present(errvc, animated: flag)
        case .success:
            guard let match = matchList.lastMatch else {
                if ignoreError {
                    return
                }
                let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
                let state = FJRouterState(matches: matchList)
                let errvc = errorBuilder(state)
                errvc.modalPresentationStyle = .fullScreen
                fromController?.present(errvc, animated: flag)
                return
            }
            let state = FJRouterState(matches: matchList, match: match)
            let fromController = sourceController ?? apptopController(UIApplication.shared.versionkKeyWindow?.rootViewController)
            switch match.route.builder {
            case .default(let action):
                let destController = action(state)
                destController.modalPresentationStyle = .fullScreen
                fromController?.present(destController, animated: flag)
            case .display(let action):
                _ = action(fromController, state)
            case .none:
                return
            }
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
