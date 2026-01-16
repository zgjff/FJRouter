//
//  FJRouteTargetInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

/// 路由拦截器协议
public protocol FJRouteTargetInterceptor: Sendable {
    func prepare()
    
    func willMath()
    
    func didMatch()
}
