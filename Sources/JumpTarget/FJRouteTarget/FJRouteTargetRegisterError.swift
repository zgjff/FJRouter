//
//  FJRouteTargetRegisterError.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/12.
//

import Foundation

extension FJRouteTarget {
    /// 注册添加路由错误
    public enum RegisterError: Error {
        /// 路由uri解析错误
        case uri(target: any FJRouteTargetType, err: FJRouteTarget.RegisterURIError)
        
        /// 同一个路由uri中解析出相同名称的`parameter`
        case sameParameter(target: any FJRouteTargetType, parameter: String)
        
        /// 子路由以`/`结尾: 除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾
        case childrenTargetUriSuffixWithSlash(target: any FJRouteTargetType)
        
        /// 子路由节点过深, 可能存在循环指向
        case childrenTargetNodeTooDepth(target: any FJRouteTargetType, parentTarget: any FJRouteTargetType)
    }
}
