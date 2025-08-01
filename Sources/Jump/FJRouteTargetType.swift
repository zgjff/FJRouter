//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2025/7/31.
//

import Foundation

public protocol FJRouteTargetType: Sendable {
    /// 路由路径
    ///
    /// 该路径还支持路径参数. eg:
    ///
    ///     路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
    ///
    var path: String { get }
    
    /// 路由名称: 此参数可以为`nil`, 但是如果一旦设置了不为`nil`, 必须不能为空, 否则会抛出`FJRouter.RegisterURIError.emptyName`错误;
    /// 而且要保证`name`的唯一性, 否则在注册的时候会触发断言assert
    var name: String? { get }
    
    /// 路由参数. eg:
    ///
    ///     如path为`/family/:fid`, 则必须提供fid, ["fid": "xxx"]
    ///     如path为`/user/:uid/books/:bid`, 则必须提供uid和bid, ["uid": "xxx", "bid": "xxx"]
    ///
    var pathParams: [String: String] { get }
    
    /// 路由查询参数. eg:
    ///
    ///     如path为`/family/:fid`, pathParams为["fid": "123"], queryParams为["p": "a", "q": "b"],
    ///     则会组合成`/family/123?p=a&q=b`;
    var queryParams: [String: String] { get }
    
    /// 构建路由方式
    var  builder: FJRoute.Builder? { get }
    
    /// 显示匹配路由控制器的方式
    var animator: FJRoute.Animator { get }
    
    /// 路由拦截器: 数组, 可以添加多个, 按顺序检查
    ///
    /// 比如:
    /// 登录检查, 用户权限检查......多个条件拦截器逻辑可以分开写.
    ///
    /// 职能单一, 方便测试
    var interceptors: [any FJRouteRedirector] { get }
    
    /// 关联的子路由: ⚠️注意循环问题
    var routes: [FJRouteTargetType] { get }
}

public extension FJRouteTargetType {
    var queryParams: [String: String] {
        return [:]
    }
    
    var animator: FJRoute.Animator {
        return { @MainActor @Sendable _ in FJRoute.AutomaticAnimator() }
    }
    
    var interceptors: [any FJRouteRedirector] {
        return []
    }
    
    var routes: [FJRouteTargetType] {
        return []
    }
}

public extension FJRouteTargetType {
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
