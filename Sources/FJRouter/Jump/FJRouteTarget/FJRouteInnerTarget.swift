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
        /// 路由链中的位置
        private(set) var chainDepth: Int
        /// 路由对应正则表达式
        let regExp: NSRegularExpression?
        /// 路由`path`解析出来的参数名称数组
        let pathParameters: [String]
        private let assertErrorInDebug: Bool
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
                self.assertErrorInDebug = assertErrorInDebug
                self.originalTarget = originalTarget
                self.parentTarget = nil
                self.chainDepth = 0
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
//        init(originalTarget: any FJRouteTargetType, assertErrorInDebug: Bool) throws(FJRouteTarget.RegisterError) {
//            if originalTarget.builder == nil && originalTarget.interceptors.isEmpty {
//                if assertErrorInDebug {
//                    assert(false, "路由\(String(describing: originalTarget))没有builder, interceptors也为空")
//                }
//                throw .noPage
//            }
//            let p = originalTarget.uri.path.trimmingCharacters(in: .whitespacesAndNewlines)
//            if p.isEmpty {
//                if assertErrorInDebug {
//                    assert(false, "路由\(String(describing: originalTarget))的path不能为空")
//                }
//                throw .uri(target: originalTarget, err: .emptyPath)
//            }
//            
//            if p != "/" && p.hasSuffix("/") {
//                if assertErrorInDebug {
//                    assert(false, "除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾. 当前路由: \(String(describing: originalTarget))")
//                }
//                throw .uriSuffixWithSlash(target: originalTarget)
//            }
//            
//            do {
//                (regExp, pathParameters) = try originalTarget.uri.resolveRouteInfo()
//                
//                self.originalTarget = originalTarget
//                self.parentTarget = nil
//                self.chainDepth = 0
//                
//                var cp: Set<String> = []
//                for parameter in pathParameters {
//                    if cp.contains(parameter) {
//                        if assertErrorInDebug {
//                            assert(false, "路由\(String(describing: originalTarget))的path解析出包含相同的参数名称: \(parameter)")
//                        }
//                        throw FJRouteTarget.RegisterError.sameParameter(target: originalTarget, parameter: parameter)
//                    }
//                    cp.insert(parameter)
//                }
//                
//                var sits: [InnerTargetType] = []
//                for oc in originalTarget.children {
//                    let ic = try FJRouteTarget.InnerTargetType(originalTarget: oc, parentTarget: self, chainDepth: chainDepth + 1, assertErrorInDebug: assertErrorInDebug)
//                    sits.append(ic)
//                }
//                subInnerTargets = sits
//            } catch {
//                if let err = error as? FJRouteTarget.RegisterURIError {
//                    throw .uri(target: originalTarget, err: err)
//                }
//                if let err = error as? FJRouteTarget.RegisterError {
//                    throw err
//                }
//                // 不会出现, 但是必须得返回
//                throw .uri(target: originalTarget, err: .emptyPath)
//            }
//        }
//        
//        private init(originalTarget: any FJRouteTargetType, parentTarget: InnerTargetType, chainDepth: Int, assertErrorInDebug: Bool) throws(FJRouteTarget.RegisterError) {
//            if chainDepth > 99 {
//                if assertErrorInDebug {
//                    assert(false, "⚠️\(String(describing: originalTarget))在整个路由链路中位置过深, 可能是子路由循环指向问题, 请仔细排查")
//                }
//                throw .childrenTargetNodeTooDepth(target: originalTarget, parentTarget: parentTarget.originalTarget)
//            }
//            if originalTarget.builder == nil && originalTarget.interceptors.isEmpty {
//                if assertErrorInDebug {
//                    assert(false, "路由\(String(describing: originalTarget))没有builder, interceptors也为空")
//                }
//                throw .noPage
//            }
//            let p = originalTarget.uri.path.trimmingCharacters(in: .whitespacesAndNewlines)
//            if p.isEmpty {
//                if assertErrorInDebug {
//                    assert(false, "路由\(String(describing: originalTarget))的path不能为空")
//                }
//                throw .uri(target: originalTarget, err: .emptyPath)
//            }
//            
//            if p != "/" && p.hasSuffix("/") {
//                if assertErrorInDebug {
//                    assert(false, "除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾. 当前路由: \(String(describing: originalTarget))")
//                }
//                throw .uriSuffixWithSlash(target: originalTarget)
//            }
//            
//            do {
//                (regExp, pathParameters) = try originalTarget.uri.resolveRouteInfo()
//                
//                self.originalTarget = originalTarget
//                self.parentTarget = parentTarget
//                self.chainDepth = chainDepth
//                
//                var cp: Set<String> = []
//                for parameter in pathParameters {
//                    if cp.contains(parameter) {
//                        if assertErrorInDebug {
//                            assert(false, "路由\(String(describing: originalTarget))的path解析出包含相同的参数名称: \(parameter)")
//                        }
//                        throw FJRouteTarget.RegisterError.sameParameter(target: originalTarget, parameter: parameter)
//                    }
//                    cp.insert(parameter)
//                }
//                
//                var ppt: InnerTargetType? = parentTarget
//                while let p = ppt {
//                    for pp in p.pathParameters {
//                        if pathParameters.contains(pp) {
//                            if assertErrorInDebug {
//                                assert(false, "在路由: \(String(describing: p.originalTarget))及其子路由: \(String(describing: originalTarget))中发现重复的路由参数: \(pp)")
//                            }
//                            throw FJRouteTarget.RegisterError.sameParameterInLink(parentTarget: p.originalTarget, target: originalTarget, parameter: pp)
//                        }
//                    }
//                    ppt = p.parentTarget
//                }
//                var sits: [InnerTargetType] = []
//                for oc in originalTarget.children {
//                    let ic = try FJRouteTarget.InnerTargetType(originalTarget: oc, parentTarget: self, chainDepth: chainDepth + 1, assertErrorInDebug: assertErrorInDebug)
//                    sits.append(ic)
//                }
//                subInnerTargets = sits
//            } catch {
//                if let err = error as? FJRouteTarget.RegisterURIError {
//                    throw .uri(target: originalTarget, err: err)
//                }
//                if let err = error as? FJRouteTarget.RegisterError {
//                    throw err
//                }
//                throw .uri(target: originalTarget, err: .emptyPath)
//            }
//        }
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
    
    func tryAddParent(ptarget: FJRouteTarget.InnerTarget) throws(FJRouteTarget.RegisterError) {
        do { // check pt == ot
            let tu = ptarget.originalTarget.uri
            let ou = originalTarget.uri
            if tu.id == ou.id && tu.path == ou.path && tu.caseSensitive == ou.caseSensitive {
                if assertErrorInDebug {
                    assert(false, "路由\(String(describing: originalTarget))与其父路由:\(String(describing: originalTarget))是同一个")
                }
                throw .loop(target: originalTarget, parentTarget: ptarget.originalTarget)
            }
        }
        
        do { // check pathParameters
            // TODO: - 中间隔了一层就检测不出来
            var cp: Set<String> = Set(pathParameters)
            for pp in ptarget.pathParameters {
                if cp.contains(pp) {
                    if assertErrorInDebug {
                        assert(false, "路由\(String(describing: ptarget.originalTarget))与路由\(String(describing: originalTarget))的path解析出包含相同的参数名称: \(pp)")
                    }
                    throw .sameParameterInLink(parentTarget: ptarget.originalTarget, target: originalTarget, parameter: pp)
                }
                cp.insert(pp)
            }
        }
        
        do { // TODO: - check loop
            let pto = ptarget.originalTarget
            var cit: FJRouteTarget.InnerTarget? = self
            while let wcit = cit {
                let tu = ptarget.originalTarget.uri
                let ou = originalTarget.uri
                if tu.id == ou.id && tu.path == ou.path && tu.caseSensitive == ou.caseSensitive {
                    if assertErrorInDebug {
                        assert(false, "路由\(String(describing: originalTarget))与其父路由:\(String(describing: originalTarget))是同一个")
                    }
                    throw .loop(target: originalTarget, parentTarget: ptarget.originalTarget)
                }
                
            }
            //                var ppt: InnerTargetType? = parentTarget
            //                while let p = ppt {
            //                    for pp in p.pathParameters {
            //                        if pathParameters.contains(pp) {
            //                            if assertErrorInDebug {
            //                                assert(false, "在路由: \(String(describing: p.originalTarget))及其子路由: \(String(describing: originalTarget))中发现重复的路由参数: \(pp)")
            //                            }
            //                            throw FJRouteTarget.RegisterError.sameParameterInLink(parentTarget: p.originalTarget, target: originalTarget, parameter: pp)
            //                        }
            //                    }
            //                    ppt = p.parentTarget
            //                }
        }
        
        ptarget.childrenTargets.append(self)
        parentTarget = ptarget
        chainDepth += 1
        for ct in childrenTargets {
            ct.chainDepth = chainDepth + 1
        }
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
