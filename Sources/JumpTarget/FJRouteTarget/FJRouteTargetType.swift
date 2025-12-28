//
//  FJRouteTargetType.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

/// 路由对象协议
public protocol FJRouteTargetType: Sendable {
    /// 路由路径: 强烈建议子路由的`path`不要以`/`为开头
    ///
    /// 该路径还支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    var path: any FJRouteTargetPath { get }
    
    /// 路由参数, 如果提供的与path中需要的不一致, 或者缺少, 则后续在匹配的时候抛出错误. eg:
    ///
    ///     如path为`/family/:fid`, 则必须提供fid, ["fid": "xxx"]
    ///     如path为`/user/:uid/books/:bid`, 则必须提供uid和bid, ["uid": "xxx", "bid": "xxx"]
    var pathParams: [String: Any] { get }
    
    /// 构建路由方式
    var  builder: FJRouteTarget.Builder? { get }
    
    /// 显示匹配路由控制器的方式
    var animator: FJRouteTarget.Animator { get }
    
    /// 路由拦截器: 数组, 可以添加多个, 按顺序检查
    ///
    /// 比如:
    /// 登录检查, 用户权限检查......多个条件拦截器逻辑可以分开写.
    ///
    /// 职能单一, 方便测试
    var interceptors: [any FJRouteTargetInterceptor] { get }
    
    /// 关联的子路由: ⚠️注意循环问题
    var subTargets: [any FJRouteTargetType] { get }
}

extension FJRouteTargetType {
    public var interceptors: [any FJRouteTargetInterceptor] {
        return []
    }
    
    public var subTargets: [any FJRouteTargetType] {
        return []
    }
}

extension FJRouteTargetType {
    public func show() async {
        await FJRouter.jumpa().go(self)
    }
}
