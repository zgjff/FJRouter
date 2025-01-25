//
//  FJRouter+Resource.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 资源中心
    public static func resource() -> any FJRouterResourceable {
        FJRouter.ResourceImpl.shared
    }
}

/// 路由资源协议
public protocol FJRouterResourceable {
//    func put()
//    func get()
}
