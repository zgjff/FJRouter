//
//  AsyncStreamCallback.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation

extension FJRouter {
    /// 使用`AsyncStream`进行callback
    struct AsyncStreamCallback: FJRouterCallbackable {
        let stream: AsyncStream<FJRouter.CallbackItem>
        private let continuation: AsyncStream<FJRouter.CallbackItem>.Continuation
        init() {
            (stream, continuation) = AsyncStream.makeStream(of: FJRouter.CallbackItem.self)
        }
        
        func dispatch(_ item: FJRouter.CallbackItem) {
            continuation.yield(item)
        }
        
        func finish() {
            continuation.finish()
        }
    }
}
