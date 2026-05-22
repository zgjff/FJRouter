//
//  FJRouteTargetRegisterError.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/12.
//

import Foundation

extension FJRouteTarget {
    /// 注册添加路由错误
    public enum RegisterError: @unchecked Sendable, Error {
        /// builder以及interceptors均没有设置
        case noPage
        
        /// 路由uri解析错误
        case uri(target: any FJRouteTargetType, err: FJRouteTarget.RegisterURIError)
        
        /// 同一个路由uri中解析出相同名称的`parameter`
        // TODO: - 事例
        case sameParameter(target: any FJRouteTargetType, parameter: String)
        
        /// 父路由与其子路由uri中解析出相同名称的`parameter`
        // TODO: - 事例
        case sameParameterInLink(parentTarget: any FJRouteTargetType, target: any FJRouteTargetType, parameter: String)
        
        /// 路由以`/`结尾: 除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾
        ///
        /// why: 在`URL`标准规定里, queryItems不能直接放在/后面,
        /// 在使用Universal link时, url基本会有queryItems, 此时正确的写法是
        ///
        ///     https://xx.xxx.com/path?a=1&b=2
        ///
        /// 而非
        ///
        ///     https://xx.xxx.com/?a=1&b=2
        case uriSuffixWithSlash(target: any FJRouteTargetType)
        
        /// 同一个路由链路中存在循环指向
        case loop(target: any FJRouteTargetType, parentTarget: any FJRouteTargetType)
        
        /// 同一个路由下的子路由中存在相同的uri path判定
        case equtalPath(lhs: any FJRouteTargetType, rhs: any FJRouteTargetType, parentTarget: any FJRouteTargetType)
    }
}

extension FJRouteTarget.RegisterError: Equatable {
    public static func == (lhs: FJRouteTarget.RegisterError, rhs: FJRouteTarget.RegisterError) -> Bool {
        switch (lhs, rhs) {
        case (.noPage, .noPage):
            return true
        case let (.uri(lt, err: lr), .uri(rt, err: rr)):
            return equal(lhs: lt, rhs: rt) && (lr == rr)
        case let (.sameParameter(lt, parameter: lp), .sameParameter(rt, parameter: rp)):
            return (lp == rp) && equal(lhs: lt, rhs: rt)
        case let (.sameParameterInLink(lpt, target: lt, parameter: lp), .sameParameterInLink(rpt, target: rt, parameter: rp)):
            return (lp == rp) && equal(lhs: lt, rhs: rt) && equal(lhs: lpt, rhs: rpt)
        case let (.uriSuffixWithSlash(target: lt), .uriSuffixWithSlash(target: rt)):
            return equal(lhs: lt, rhs: rt)
        case let (.loop(target: lt, parentTarget: lpt), .loop(target: rt, parentTarget: rpt)):
            return equal(lhs: lt, rhs: rt) && equal(lhs: lpt, rhs: rpt)
        case let (.equtalPath(lhs: llt, rhs: lrt, parentTarget: lpt), .equtalPath(lhs: rlt, rhs: rrt, parentTarget: rpt)):
            return equal(lhs: llt, rhs: rlt) && equal(lhs: lrt, rhs: rrt) && equal(lhs: lpt, rhs: rpt)
        default:
            return false
        }
    }
}

extension FJRouteTarget.RegisterError {
    private static func equal(lhs: any FJRouteTargetType, rhs: any FJRouteTargetType) -> Bool {
        let luri = lhs.uri
        let ruri = rhs.uri
        return luri.id == ruri.id && luri.path == ruri.path && luri.caseSensitive == ruri.caseSensitive
    }
}
