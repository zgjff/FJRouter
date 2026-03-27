//
//  FJRouteJumpProvider.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/27.
//

import Foundation

extension FJRouter {
    /// 创建新的路由跳转管理中心。
    /// 注意⚠️: 返回的并非是单例对象, 需要应用层app持有此对象;
    ///
    /// - Parameter config: 配置
    /// - Returns: 具体的路由跳转管理
    public static func startJumpProvider(withConfig config: (_ config: inout FJRouteJumpProviderConfig) -> () = { _ in }) -> any FJRouteJumpProvider {
        var fconfig = FJRouteJumpProviderConfig()
        config(&fconfig)
        return FJRouteJumpProviderImpl(config: fconfig)
    }
}

/// 路由跳转管理协议
public protocol FJRouteJumpProvider: Sendable {
    /// 注册路由
    ///
    /// TODO: - 其它注册相关注释： 重复注册/注册子路由.....
    ///
    /// - Parameter route: 路由描述
    func register(_ route: any FJRouteTargetType) async throws(FJRouteTarget.RegisterError)
    
    // TODO: - 返回可取消, 因为`FJRouteTargetInterceptor`是异步耗时操作, 可能时间比较长
    func go(_ route: any FJRouteTargetType) async
    
    func go(_ url: URL) async
    
    /// 尝试跳转
    /// - Parameter maybeRoute: 路由对象
    ///
    /// why: 在模块化开发下, 有可能路由的声明和实现是放在不同的模块中的; 需要跳转的地方无法访问到实现路由的模块,
    /// 也就无法确定声明是否实现了`FJRouteTargetType`协议.
    ///
    /// 在实现内部, 会优先判断`maybeRoute`是否实现了`FJRouteTargetType`协议, 实现了则走`func go(_ route: any FJRouteTargetType) async`方法;
    ///
    /// 其次再判断`maybeRoute`如果是`URL`, 则走`func go(_ url: URL) async`方法;
    func tryGo(_ maybeRoute: Any) async
    
    func viewControllerFor(route: any FJRouteTargetType, ignoreInterceptor: Bool) async throws -> IViewController
    
    func viewControllerFor(url: URL, ignoreInterceptor: Bool) async throws -> IViewController
    
    func viewControllerFor(maybeRoute route: Any, ignoreInterceptor: Bool) async throws -> IViewController
}
