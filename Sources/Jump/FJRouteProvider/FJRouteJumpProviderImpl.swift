//
//  FJRouteJumpProviderImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation
import UIKit
extension FJRouteJumpProvider {
    internal actor Impl: FJRouteJumpProviderable {
        private var routes: [FJRouteTarget.InnerTarget]
        private var redirectLimit: UInt = 5
        init() {
            routes = Array(unsafeUninitializedCapacity: 50, initializingWith: { _, _ in })
        }
    }
}

// MARK: - register
extension FJRouteJumpProvider.Impl {
    func registerRoute(_ target: any FJRouteTargetType) async {
        let currentIt = FJRouteTarget.InnerTarget(target: target)
        routes.append(currentIt)
    }
}

// MARK: - redirect
extension FJRouteJumpProvider.Impl {
    func setRedirectLimit(_ limit: UInt) async {
        redirectLimit = max(1, limit)
    }
}

// MARK: - match
extension FJRouteJumpProvider.Impl {
    func match(with extra: @autoclosure @Sendable @escaping () -> Any?) async throws(FJRouter.JumpMatchError) -> FJRouteJumpProvider.MatchResult {
        return FJRouteJumpProvider.MatchResult(extra: extra)
    }
}
