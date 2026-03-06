//
//  FJRouteJumpProviderConfig.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/12.
//

import Foundation
/// 路由跳转管理中心配置
public struct FJRouteJumpProviderConfig: @unchecked Sendable {
    /// 当注册路由错误时, 是否触发系统`assert`断言方法: 系统`assert`断言方法只在`Debug`环境生效。
    ///
    /// 此参数修饰符非`public`, 只在框架内部可修改, 方便`test`; 项目引用时是`true`, 也即是鼓励在开发阶段发现
    /// 路由的`uri.path`问题.
    ///
    /// 如果为`false`, 则注册时path有问题, 也不会触发`assert`断言;
    /// 如果为`true`, 可以在开发阶段提前发现注册路由相关错误, 触发`assert`断言:
    ///
    /// 1: path为空;
    ///
    /// 2: 路由path中存在相同名称的参数;
    ///
    /// 3: 路由跟子路由path中存在相同名称的参数;
    ///
    /// 4: 在整个路由链路中位置过深, 可能是子路由循环指向问题;
    ///
    /// 5: 其它错误;
    var assertRegisterErrorInDebug = true
}
