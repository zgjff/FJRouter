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
    func viewController(byLocation location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws -> UIViewController {
        guard let url = URL(string: location) else {
            throw FJRouter.MatchError.errorLocUrl
        }
        let match = try await store.match(url: url, extra: extra, ignoreError: true)
        if let destvc = await core.viewController(for: match) {
            return destvc
        }
        throw FJRouter.MatchError.noBuilder
    }
    
    func viewController(byName name: String, params: [String : String], queryParams: [String : String], extra: @autoclosure @escaping @Sendable () -> (any Sendable)?) async throws -> UIViewController {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            let destvc = try await viewController(byLocation: loc, extra: extra)
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
    func go(_ location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) throws {
        Task {
            try await self.go_private(location: location, extra: extra, from: fromVC, ignoreError: ignoreError)
        }
    }
    
    func goNamed(_ name: String, params: [String : String], queryParams: [String : String], extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) throws {
        Task {
            do {
                let loc = try await self.convertLocationBy(name: name, params: params, queryParams: queryParams)
                try await self.go_private(location: loc, extra: extra, from: fromVC, ignoreError: ignoreError)
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
    
    @discardableResult
    func go(_ location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
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
    func goNamed(_ name: String, params: [String : String], queryParams: [String : String], extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async -> AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError> {
        do {
            let loc = try await convertLocationBy(name: name, params: params, queryParams: queryParams)
            return await go(loc, extra: extra, from: fromVC, ignoreError: ignoreError)
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

extension FJRouter.JumpImpl {
    /// 通过路由名称、路由参数、查询参数组装路由路径
    ///
    /// 建议在使用路由的时候使用此方法来组装路由路径。
    ///
    /// 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
    ///
    /// 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改
    /// - Parameters:
    ///   - name: 路由名称
    ///   - params: 路由参数
    ///   - queryParams: 路由查询参数
    /// - Returns: 组装之后的路由路径
    internal func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) async throws -> String {
        try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
    }
    
    private func go_trigger<T>(location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool, callback: @escaping @autoclosure () -> T) async throws -> T where T: FJRouterCallbackable {
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
    
    private func go_private(location: String, extra: @autoclosure @escaping @Sendable () -> (any Sendable)?, from fromVC: UIViewController?, ignoreError: Bool) async throws {
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
