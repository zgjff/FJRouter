//
//  FJRouter+Callback.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation
import Combine
import UIKit

extension UIViewController {
    /// 触发路由回调
    ///
    /// 如果`name`为空, 或者路由跳转方法没有使用带有`AnyPublisher`返回值的go方法, 则发送失败
    /// - Parameters:
    ///   - name: 名称
    ///   - value: 对应的值: 默认为()
    public func dispatchFJRouterCallBack(name: String, value: (any Sendable)? = ()) throws {
        guard let item = FJRouter.CallbackItem(name: name, value: value) else {
            throw FJRouter.SendCallbackError.emptyName
        }
        try dispatchFJRouterCallBack(item: item)
    }
    
    /// 触发路由回调
    ///
    /// 如果路由跳转方法没有使用带有`AnyPublisher`返回值的go方法, 则发送失败
    /// - Parameter item: 内容
    /// - Returns: 发送回调结果.`true`: 成功, `false`: 失败
    public func dispatchFJRouterCallBack(item: FJRouter.CallbackItem) throws {
        if fjroute_callback_trigger == nil {
            throw FJRouter.SendCallbackError.noTrigger
        }
        fjroute_callback_trigger?.send(item)
    }
}

extension FJRouter {
    /// 路由回调`name-value`
    public struct CallbackItem: Sendable {
        /// 名称
        public let name: String
        /// 内容
        public let value: (any Sendable)?

        public init?(name: String, value: (any Sendable)?) {
            let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if n.isEmpty {
                return nil
            }
            self.name = name
            self.value = value
        }
    }
}

extension FJRouter {
    internal final class CallbackTrigger: Sendable {
        nonisolated(unsafe) let subject: PassthroughSubject<FJRouter.CallbackItem, Never>
        
        init() {
            subject = PassthroughSubject()
        }
        
        fileprivate func send(_ item: FJRouter.CallbackItem) {
            subject.send(item)
        }
        
        deinit {
            subject.send(completion: .finished)
        }
    }
}

extension FJRouter {
    /// 发送路由回调错误
    public enum SendCallbackError: Error, Sendable {
        /// 发送的`callback`的`name`为空
        case emptyName
        /// 没有路由回调触发器, 使用路由方法错误, 请使用带有`AnyPublisher`返回值的go方法
        case noTrigger
    }
}

extension FJRouter.SendCallbackError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.emptyName, .emptyName):
            return true
        case (.noTrigger, .noTrigger):
            return true
        case (.emptyName, .noTrigger), (.noTrigger, .emptyName):
            return false
        }
    }
}

extension FJRouter.SendCallbackError: CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .emptyName:
            return "send name is empty"
        case .noTrigger:
            return "please use async go method with return AnyPublisher"
        }
    }
    
    public var debugDescription: String {
        description
    }
    
    public var localizedDescription: String {
        description
    }
    
    public var errorDescription: String? {
        description
    }
    
    public var failureReason: String? {
        description
    }
}

nonisolated(unsafe) private var fjroute_combine_callback_trigger_Key = 0
extension UIViewController {
    internal func fjroute_addCallbackTrigger() -> FJRouter.CallbackTrigger {
        let obj = FJRouter.CallbackTrigger()
        objc_setAssociatedObject(self, &fjroute_combine_callback_trigger_Key, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return obj
    }
    
    fileprivate var fjroute_callback_trigger: FJRouter.CallbackTrigger? {
        get {
            if let obj = objc_getAssociatedObject(self, &fjroute_combine_callback_trigger_Key) as? FJRouter.CallbackTrigger {
                return obj
            }
            return nil
        }
    }
}
