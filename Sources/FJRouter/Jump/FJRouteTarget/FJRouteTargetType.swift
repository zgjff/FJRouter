//
//  FJRouteTargetType.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

// TODO: - uri, interceptors, children 使用宏
// TODO: - uri: @uri("xxx"), @uri("xxxx", false)
// TODO: - interceptors: @interceptors([])
// TODO: - children:不再需要, 需要@parent(xxx)
/// 路由对象协议
public protocol FJRouteTargetType: Sendable {
    /// 路由资源: 强烈建议子路由的`path`不要以`/`为开头
    var uri: any FJRouteTargetURI { get }
    
    /// 构建路由方式
    var  builder: FJRouteTarget.Builder? { get }
    
    /// 显示匹配路由控制器的方式
    var animator: FJRouteTarget.Animator { get }
    
    /// 路由拦截器: 可以添加多个, 按照优先级`priority`顺序检查, `priority`高的先检查;会影响路由下的所有关联子路由;
    ///
    ///
    /// 比如:
    /// 登录检查, 用户权限检查......多个条件拦截器逻辑可以分开写.
    ///
    /// 职能单一, 方便测试
    var interceptors: [any FJRouteTargetInterceptor] { get }
    
    /// 关联的🧧路由: ⚠️注意循环问题
    var parent: (any FJRouteTargetType)? { get }
}

extension FJRouteTargetType {
    public var interceptors: [any FJRouteTargetInterceptor] {
        return []
    }
    
    public var parent: (any FJRouteTargetType)? {
        return nil
    }
}
