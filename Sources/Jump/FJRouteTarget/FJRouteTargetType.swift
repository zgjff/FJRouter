//
//  FJRouteTargetType.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation

/// 路由对象协议
public protocol FJRouteTargetType: Sendable {
    /// 路由路径
    ///
    /// 该路径还支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    var path: String { get }
    
    /// 路由名称: 此参数可以为`nil`, 但是如果一旦设置了不为`nil`, 必须不能为空, 否则会抛出`FJRouter.RegisterURIError.emptyName`错误;
    /// 而且要保证`name`的唯一性, 否则在注册的时候会触发断言assert
    var name: String? { get }
    
    /// 路由参数, 如果提供的与path中需要的不一致, 或者缺少, 则后续在匹配的时候抛出错误. eg:
    ///
    ///     如path为`/family/:fid`, 则必须提供fid, ["fid": "xxx"]
    ///     如path为`/user/:uid/books/:bid`, 则必须提供uid和bid, ["uid": "xxx", "bid": "xxx"]
    var pathParams: [String: String] { get }
    
    /// 路由查询参数, 即路由参数之外的参数. eg:
    ///
    ///     如path为`/family/:fid`, pathParams为["fid": "123"], queryParams为["p": "a", "q": "b"],
    ///     则会组合成`/family/123?p=a&q=b`;
    var queryParams: [String: String] { get }
    
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
    var subTargets: [FJRouteTargetType] { get }
}

public extension FJRouteTargetType {
    var queryParams: [String: String] {
        return [:]
    }
    
    var animator: FJRouteTarget.Animator {
        return FJRouteTarget.Animator { _ in
            FJRoute.AutomaticAnimator()
        }
    }
    
    var interceptors: [any FJRouteTargetInterceptor] {
        return []
    }
    
    var subTargets: [FJRouteTargetType] {
        return []
    }
}

public extension FJRouteTargetType {
    /// 解析出匹配正则, 以及参数数组.具体的匹配数据以及测试代码可以参考: `FJPathUtilsTests`
    ///
    ///  无参数:
    ///
    ///     path为"/settings/detail", 则解析出的正则为: "^\/settings\/detail(?=/|$)", 参数数组为[]
    ///  一个参数:
    ///
    ///     path为"/user/:id", 则解析出的正则为: "^\/user\/(?<id>[^/]+)(?=/|$)", 参数数组为["id"]
    ///  多个参数:
    ///
    ///     path为"/user/:id/book/:bookId", 则解析出的正则为: "^\/user\/(?<id>[^/]+)\/book\/(?<bookId>[^/]+)(?=/|$)", 参数数组为["id", "bookId"]
    func resolve() async throws(FJRouter.RegisterURIError) -> (regExp: NSRegularExpression, pathParameters: [String]) {
        let p = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if p.isEmpty {
            throw FJRouter.RegisterURIError.emptyPath
        }
        let n = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let n, n.isEmpty {
            throw FJRouter.RegisterURIError.emptyName
        }
        do {
            let (regExp, pathParameters) = try await FJPathUtils.default.patternToRegExp(pattern: p)
            return (regExp, pathParameters)
        } catch {
            throw FJRouter.RegisterURIError.regExp(error)
        }
    }
}
