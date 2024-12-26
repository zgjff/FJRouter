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
        nonisolated(unsafe) let stream: AsyncStream<FJRouter.CallbackItem>
        nonisolated(unsafe) private let continuation: AsyncStream<FJRouter.CallbackItem>.Continuation
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
