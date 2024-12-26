//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation
import Combine

protocol FJRouterCallbackable: Sendable {
    /// 触发callback
    func dispatch(_ item: FJRouter.CallbackItem)
    /// 完成
    func finish()
}

extension FJRouter {
    /// 路由callback触发器
    internal final class CallbackTrigger: Sendable {
        private let callback: any FJRouterCallbackable
        init(callback: some FJRouterCallbackable) {
            self.callback = callback
        }
        
        func dispatch(_ item: FJRouter.CallbackItem) {
            callback.dispatch(item)
        }
        
        deinit {
            callback.finish()
        }
    }
}

extension FJRouter {
    struct PassthroughSubjectCallback: FJRouterCallbackable {
        nonisolated(unsafe) let subject: PassthroughSubject<FJRouter.CallbackItem, Never>
        init() {
            subject = PassthroughSubject()
        }
        
        func dispatch(_ item: FJRouter.CallbackItem) {
            subject.send(item)
        }
        
        func finish() {
            subject.send(completion: .finished)
        }
    }
}
