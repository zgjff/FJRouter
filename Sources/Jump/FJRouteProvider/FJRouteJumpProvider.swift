//
//  FJRouteJumpProvider.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation
import UIKit

/// 路由provider命名空间
public enum FJRouteJumpProvider {}

extension FJRouteJumpProvider {
    /// 默认提供的路由跳转协议实现
    nonisolated(unsafe) public private(set) static var `default`: any FJRouteJumpProviderable = FJRouteJumpProvider.Impl()
}
