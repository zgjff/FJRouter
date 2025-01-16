//
//  FJRouter+Event.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 事件总线
    public static let event = FJRouter.Event()
}

extension FJRouter {
    /// 事件总线
    final public class Event: Sendable {
        
        fileprivate init() {
        }
    }
}
