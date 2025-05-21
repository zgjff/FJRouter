//
//  UIViewController+FJRouterCallback.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/27.
//

#if canImport(UIKit)
import Foundation
import UIKit

extension FJRouter.Wrapper where Object: UIViewController {
    /// 触发路由回调
    ///
    /// 如果`name`为空, 或者路由跳转方法没有使用带有`AnyPublisher`返回值的go方法, 则发送失败
    /// - Parameters:
    ///   - name: 名称
    ///   - value: 对应的值: 默认为()
    public func dispatchFJRouterCallBack(name: String, value: (any Sendable)? = ()) throws(FJRouter.EmitCallbackError) {
        guard let item = FJRouter.CallbackItem(name: name, value: value) else {
            throw FJRouter.EmitCallbackError.emptyName
        }
        try dispatchFJRouterCallBack(item: item)
    }
    
    /// 触发路由回调
    ///
    /// - Parameter item: 内容
    public func dispatchFJRouterCallBack(item: FJRouter.CallbackItem) throws(FJRouter.EmitCallbackError) {
        if fjroute_callback_dispatcher == nil {
            throw FJRouter.EmitCallbackError.noTrigger
        }
        fjroute_callback_dispatcher?.dispatch(item)
    }
}

nonisolated(unsafe) private var fjroute_combine_callback_dispatcher_e5WD25xCn_UygMO5_Key = 0
extension FJRouter.Wrapper where Object: UIViewController {
    @discardableResult
    internal func addCallbackTrigger(callback: some FJRouterCallbackable) -> FJRouter.CallbackDispatcher {
        let obj = FJRouter.CallbackDispatcher(callback: callback)
        objc_setAssociatedObject(self, &fjroute_combine_callback_dispatcher_e5WD25xCn_UygMO5_Key, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return obj
    }
    
    fileprivate var fjroute_callback_dispatcher: FJRouter.CallbackDispatcher? {
        get {
            if let obj = objc_getAssociatedObject(self, &fjroute_combine_callback_dispatcher_e5WD25xCn_UygMO5_Key) as? FJRouter.CallbackDispatcher {
                return obj
            }
            return nil
        }
    }
}

#endif
