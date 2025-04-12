//
//  FJRouterJumpImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

#if canImport(UIKit)
import UIKit
import Foundation
import Combine

extension FJRouter {
    /// 路由管理中心
    final class JumpImpl: FJRouterJumpable, Sendable {
        internal static let shared = JumpImpl()
        fileprivate let store: FJRouter.JumpStore
        fileprivate let core: FJRouter.JumpCore
        private init() {
            core = FJRouter.JumpCore()
            store = FJRouter.JumpStore()
        }
    }
}

// MARK: - set
extension FJRouter.JumpImpl {
    func registerRoute(_ route: FJRoute) async {
        await store.addRoute(route)
    }

    func setRedirectLimit(_ limit: UInt) async {
        await store.setRedirectLimit(limit)
    }
    
    func setErrorBuilder(_ builder: @escaping (@MainActor @Sendable (_ state: FJRouterState) -> UIViewController)) async {
        await withCheckedContinuation { continuation in
            self.core.errorBuilder = builder
            continuation.resume()
        }
    }
    
    func canOpen(url: URL) async -> Bool {
        await store.canOpen(url: url)
    }
    
    func setTopController(action: @escaping @MainActor (_ current: UIViewController?) -> UIViewController?) async {
        await withCheckedContinuation { continuation in
            self.core.apptopController = action
            continuation.resume()
        }
    }
}

// MARK: - get
extension FJRouter.JumpImpl {
    func viewController(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws(FJRouter.JumpMatchError) -> UIViewController {
        do {
            let loc = try await store.convertLocation(by: uri)
            guard let url = URL(string: loc) else {
                throw FJRouter.JumpMatchError.errorLocUrl
            }
            let match = try await store.match(url: url, extra: extra, ignoreError: true)
            guard let lastMatch = match.lastMatch else {
                throw FJRouter.JumpMatchError.notFind
            }
            if lastMatch.route.builder == nil {
                throw FJRouter.JumpMatchError.noBuilder
            }
            if let destvc = await core.viewController(for: match) {
                return destvc
            }
            throw FJRouter.JumpMatchError.noBuilder
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.JumpMatchError.convertNameLoc(err)
            }
            if let err = error as? FJRouter.JumpMatchError {
                throw err
            }
            throw FJRouter.JumpMatchError.cancelled
        }
    }
}

// MARK: - go
extension FJRouter.JumpImpl {
    @discardableResult
    func go(_ uri: FJRouter.URI, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async throws(FJRouter.JumpMatchError) -> AnyPublisher<FJRouter.CallbackItem, Never> {
        do {
            let loc = try await store.convertLocation(by: uri)
            let result = try await go_trigger(location: loc, extra: extra, from: fromVC, ignoreError: ignoreError, callback: FJRouter.JumpPassthroughSubjectCallback())
            return result.subject.eraseToAnyPublisher()
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.JumpMatchError.convertNameLoc(err)
            }
            if let err = error as? FJRouter.JumpMatchError {
                throw err
            }
            throw FJRouter.JumpMatchError.cancelled
        }
    }
}

extension FJRouter.JumpImpl {    
    func convertLocation(by uri: FJRouter.URI) async throws(FJRouter.ConvertError) -> String {
        try await store.convertLocation(by: uri)
    }
    
    private func go_trigger<T>(location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool, callback: @escaping @autoclosure () -> T) async throws(FJRouter.JumpMatchError) -> T where T: FJRouterCallbackable {
        guard let url = URL(string: location) else {
            throw FJRouter.JumpMatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: ignoreError)
        let cb = callback()
        try await core.go(matchList: match, sourceController: fromVC, ignoreError: ignoreError, animated: true, callback: cb)
        return cb
    }
}

#endif
