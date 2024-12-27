//
//  UIViewController+FJRouterCallback.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/27.
//

import Foundation
import UIKit

extension UIViewController {
    /// 触发路由回调
    ///
    /// 如果`name`为空, 或者路由跳转方法没有使用带有`AnyPublisher`返回值的go方法, 则发送失败
    /// - Parameters:
    ///   - name: 名称
    ///   - value: 对应的值: 默认为()
    public func triggerFJRouterCallBack(name: String, value: (any Sendable)? = ()) throws {
        guard let item = FJRouter.CallbackItem(name: name, value: value) else {
            throw FJRouter.DispatchCallbackError.emptyName
        }
        try triggerFJRouterCallBack(item: item)
    }
    
    /// 触发路由回调
    ///
    /// 如果路由跳转方法没有使用带有`AnyPublisher`返回值的go方法, 则发送失败
    /// - Parameter item: 内容
    /// - Returns: 发送回调结果.`true`: 成功, `false`: 失败
    public func triggerFJRouterCallBack(item: FJRouter.CallbackItem) throws {
        if fjroute_callback_trigger == nil {
            throw FJRouter.DispatchCallbackError.noTrigger
        }
        fjroute_callback_trigger?.dispatch(item)
    }
}

nonisolated(unsafe) private var fjroute_combine_callback_trigger_Key = 0
extension UIViewController {
    @discardableResult
    internal func fjroute_addCallbackTrigger(callback: some FJRouterCallbackable) -> FJRouter.CallbackTrigger {
        let obj = FJRouter.CallbackTrigger(callback: callback)
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