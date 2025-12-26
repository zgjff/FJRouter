//
//  FJRouteTargetInterceptor.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

public protocol FJRouteTargetInterceptor: Sendable {
    func prepare()
    
    func willMath()
    
    
    
    func didMatch()
}
