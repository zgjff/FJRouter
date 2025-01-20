//
//  JumpPassthroughSubjectCallback.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation
import Combine
extension FJRouter {
    /// 使用`PassthroughSubject`进行callback
    struct JumpPassthroughSubjectCallback: FJRouterCallbackable {
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
