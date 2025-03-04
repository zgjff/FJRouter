//
//  UIViewController+FJRouterCallback.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/27.
//

import Foundation
#if canImport(UIKit)
import UIKit

extension UIViewController {
    /// 触发路由回调
    ///
    /// 如果`name`为空, 或者路由跳转方法没有使用带有`AnyPublisher`返回值的go方法, 则发送失败
    /// - Parameters:
    ///   - name: 名称
    ///   - value: 对应的值: 默认为()
    public func emitFJRouterCallBack(name: String, value: (any Sendable)? = ()) throws(FJRouter.EmitCallbackError) {
        guard let item = FJRouter.CallbackItem(name: name, value: value) else {
            throw FJRouter.EmitCallbackError.emptyName
        }
        try emitFJRouterCallBack(item: item)
    }
    
    /// 触发路由回调
    ///
    /// - Parameter item: 内容
    public func emitFJRouterCallBack(item: FJRouter.CallbackItem) throws(FJRouter.EmitCallbackError) {
        if fjroute_callback_emitter == nil {
            throw FJRouter.EmitCallbackError.noTrigger
        }
        fjroute_callback_emitter?.dispatch(item)
    }
}

nonisolated(unsafe) private var fjroute_combine_callback_trigger_e5WD25xCn_UygMO5_Key = 0
extension UIViewController {
    @discardableResult
    internal func fjroute_addCallbackTrigger(callback: some FJRouterCallbackable) -> FJRouter.CallbackEmitter {
        let obj = FJRouter.CallbackEmitter(callback: callback)
        objc_setAssociatedObject(self, &fjroute_combine_callback_trigger_e5WD25xCn_UygMO5_Key, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return obj
    }
    
    fileprivate var fjroute_callback_emitter: FJRouter.CallbackEmitter? {
        get {
            if let obj = objc_getAssociatedObject(self, &fjroute_combine_callback_trigger_e5WD25xCn_UygMO5_Key) as? FJRouter.CallbackEmitter {
                return obj
            }
            return nil
        }
    }
}

#endif
