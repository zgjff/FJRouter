//
//  FJRouterJumpImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import UIKit
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
    
    func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) async throws -> String {
        try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
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
    func viewController(forLocation location: String, extra: (any Sendable)? = nil) async throws -> UIViewController {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: true)
        if let destvc = await core.viewController(for: match) {
            return destvc
        }
        throw FJRouter.MatchError.noBuilder
    }
    
    func viewController(forName name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil) async throws -> UIViewController {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            let destvc = try await viewController(forLocation: loc, extra: extra)
            return destvc
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
}

// MARK: - go
extension FJRouter.JumpImpl {
    func go(location: String, extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            try await go_private(location: location, extra: extra, from: fromVC, ignoreError: ignoreError)
        }
    }
    
    func goNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) throws {
        Task {
            do {
                let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
                try await go_private(location: loc, extra: extra, from: fromVC, ignoreError: ignoreError)
            } catch {
                if let err = error as? FJRouter.ConvertError {
                    throw FJRouter.MatchError.convertNameLoc(err)
                } else if let err = error as? FJRouter.MatchError {
                    throw err
                } else {
                    throw FJRouter.MatchError.cancelled
                }
            }
        }
    }
}

// MARK: - callback go
extension FJRouter.JumpImpl {
    @discardableResult
    func go(location: String, extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        do {
            let result = try await go_trigger(location: location, extra: extra, from: fromVC, ignoreError: ignoreError, callback: FJRouter.JumpPassthroughSubjectCallback())
            return result.subject.setFailureType(to: FJRouter.MatchError.self).eraseToAnyPublisher()
        } catch {
            let gerr: FJRouter.MatchError
            if let err = error as? FJRouter.ConvertError {
                gerr = .convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                gerr = err
            } else {
                gerr = FJRouter.MatchError.cancelled
            }
            return Fail(error: gerr).eraseToAnyPublisher()
        }
    }
    
    @discardableResult
    func goNamed(_ name: String, params: [String: String] = [:], queryParams: [String: String] = [:], extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            return await go(location: loc, extra: extra, from: fromVC, ignoreError: ignoreError)
        } catch {
            let gerr: FJRouter.MatchError
            if let err = error as? FJRouter.ConvertError {
                gerr = .convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                gerr = err
            } else {
                gerr = FJRouter.MatchError.cancelled
            }
            return Fail(error: gerr).eraseToAnyPublisher()
        }
    }
}

// MARK: - private
extension FJRouter.JumpImpl {
    func go_trigger<T>(location: String, extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false, callback: @escaping @autoclosure () -> T) async throws -> T where T: FJRouterCallbackable {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        do {
            let match = try await store.match(url: url, extra: extra, ignoreError: ignoreError)
            guard let vc = await core.go(matchList: match, sourceController: fromVC, ignoreError: ignoreError, animated: true) else {
                throw FJRouter.MatchError.notFind
            }
            let cb = callback()
            await vc.fjroute_addCallbackTrigger(callback: cb)
            return cb
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
    
    func go_private(location: String, extra: (any Sendable)? = nil, from fromVC: UIViewController? = nil, ignoreError: Bool = false) async throws {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        do {
            let match = try await store.match(url: url, extra: extra, ignoreError: ignoreError)
            await core.go(matchList: match, sourceController: fromVC, ignoreError: ignoreError, animated: true)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.MatchError.convertNameLoc(err)
            } else if let err = error as? FJRouter.MatchError {
                throw err
            } else {
                throw FJRouter.MatchError.cancelled
            }
        }
    }
}
