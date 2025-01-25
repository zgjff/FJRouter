//
//  FJRouterResourceImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 事件总线
    internal struct ResourceImpl: Sendable {
        internal static let shared = ResourceImpl()
//        private let store: EventStore
        private init() {
//            store = EventStore()
        }
    }
}

extension FJRouter.ResourceImpl: FJRouterResourceable {
    
}
