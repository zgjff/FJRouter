//
//  FJRouteInnerTarget.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/16.
//

import Foundation

extension FJRouteTarget {
    /// 内部具体路由
    final class InnerTarget: @unchecked Sendable {
        /// 原始路由对象
        let originalTarget: any FJRouteTargetType
        /// 父路由
        private(set) var parentTarget: InnerTarget?
        /// 子路由
        private(set) var childrenTargets: [InnerTarget] = []
        /// 路由对应正则表达式
        let regExp: NSRegularExpression?
        /// 路由`path`解析出来的参数名称数组
        let pathParameters: [String]
        init(originalTarget: any FJRouteTargetType, assertErrorInDebug: Bool) throws(FJRouteTarget.RegisterError) {
            if originalTarget.builder == nil && originalTarget.interceptors.isEmpty {
                if assertErrorInDebug {
                    assert(false, "路由\(String(describing: originalTarget))没有builder, interceptors也为空")
                }
                throw .noPage
            }
            let p = originalTarget.uri.path.trimmingCharacters(in: .whitespacesAndNewlines)
            if p.isEmpty {
                if assertErrorInDebug {
                    assert(false, "路由\(String(describing: originalTarget))的path不能为空")
                }
                throw .uri(target: originalTarget, err: .emptyPath)
            }
            if p != "/" && p.hasSuffix("/") {
                if assertErrorInDebug {
                    assert(false, "除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾. 当前路由: \(String(describing: originalTarget))")
                }
                throw .uriSuffixWithSlash(target: originalTarget)
            }
            do {
                (regExp, pathParameters) = try originalTarget.uri.resolveRouteInfo()
                var cp: Set<String> = []
                for parameter in pathParameters {
                    if cp.contains(parameter) {
                        if assertErrorInDebug {
                            assert(false, "路由\(String(describing: originalTarget))的path解析出包含相同的参数名称: \(parameter)")
                        }
                        throw FJRouteTarget.RegisterError.sameParameter(target: originalTarget, parameter: parameter)
                    }
                    cp.insert(parameter)
                }
                self.originalTarget = originalTarget
                self.parentTarget = nil
            } catch {
                if let err = error as? FJRouteTarget.RegisterURIError {
                    throw .uri(target: originalTarget, err: err)
                }
                if let err = error as? FJRouteTarget.RegisterError {
                    throw err
                }
                // 不会出现, 但是必须得返回
                throw .uri(target: originalTarget, err: .emptyPath)
            }
        }
    }
}

extension FJRouteTarget.InnerTarget {
    func find(target: any FJRouteTargetType) -> FJRouteTarget.InnerTarget? {
        let tu = target.uri
        let ou = originalTarget.uri
        if tu.id == ou.id && tu.path == ou.path && tu.caseSensitive == ou.caseSensitive {
            return self
        }
        for st in childrenTargets {
            if let sft = st.find(target: target) {
                return sft
            }
        }
        return nil
    }
    
    func tryAddParent(ptarget: FJRouteTarget.InnerTarget, assertErrorInDebug: Bool) throws(FJRouteTarget.RegisterError) {
        var parentInnerTarget: FJRouteTarget.InnerTarget? = ptarget
        var cp: Set<String> = []
        while let pit = parentInnerTarget {
            // check loop
            let pouri = pit.originalTarget.uri
            let couri = originalTarget.uri
            if pouri.id == couri.id && pouri.path == couri.path && pouri.caseSensitive == couri.caseSensitive {
                if assertErrorInDebug {
                    assert(false, "在整个路由链路上存在循环指向的路由\(String(describing: originalTarget))")
                }
                throw .loop(target: originalTarget, parentTarget: pit.originalTarget)
            }
            // check pathParameters
            cp = Set(pathParameters)
            var ppsit = pit.pathParameters.makeIterator()
            while let pp = ppsit.next() {
                if cp.contains(pp) {
                    if assertErrorInDebug {
                        assert(false, "在整个路由链路上存在循环指向的路由\(String(describing: originalTarget))")
                    }
                    throw .sameParameterInLink(parentTarget: originalTarget, target: pit.originalTarget, parameter: pp)
                }
                cp.insert(pp)
            }
            // check childrens path
            var crsit = pit.childrenTargets.makeIterator()
            while let cr = crsit.next() {
                if cr.originalTarget.uri.equtalPath(to: originalTarget.uri) {
                    if assertErrorInDebug {
                        assert(false, "父路由\(String(describing: pit.originalTarget))的childrens节点存在相同path匹配的路由\(String(describing: cr.originalTarget))和\(String(describing: originalTarget))")
                    }
                    throw .equtalPath(lhs: cr.originalTarget, rhs: originalTarget, parentTarget: pit.originalTarget)
                }
            }
            parentInnerTarget = pit.parentTarget
        }
        ptarget.childrenTargets.append(self)
        parentTarget = ptarget
    }
    
    func routeChain() -> FJRouteChain {
        var parentsRoute: [any FJRouteTargetType] = []
        var ppt: FJRouteTarget.InnerTarget? = self
        while let p = ppt?.parentTarget {
            parentsRoute.append(p.originalTarget)
            ppt = p
        }
        return FJRouteChain(route: originalTarget, parents: parentsRoute.reversed())
    }
}
