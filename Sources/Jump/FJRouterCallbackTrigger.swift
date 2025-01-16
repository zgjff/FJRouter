//
//  FJRouterCallbackTrigger.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation

/// 路由回调协议
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
