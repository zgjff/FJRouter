//
//  FJRouteInnerTarget.swift
//  FJRouter
//
//  Created by zgjff on 2026/1/16.
//

import Foundation

extension FJRouteTarget {
    /// 内部具体路由
    final class InnerTargetType: @unchecked Sendable {
        /// 原始路由对象
        private let originalTarget: any FJRouteTargetType
        /// 父路由
        private let parentTarget: InnerTargetType?
        /// 子路由
        private var subTargets: [InnerTargetType] = []
        /// 路由链中的位置
        private let chainDepth: Int
        /// 路由对应正则表达式
        private let regExp: NSRegularExpression?
        /// 路由`path`解析出来的参数名称数组
        public let pathParameters: [String]
        init(originalTarget: any FJRouteTargetType) throws {
            precondition(!originalTarget.path.path.isEmpty, "路由\(String(describing: originalTarget))的path不能为空")
            
            (regExp, pathParameters) = try originalTarget.path.resolveRouteInfo()
            
            self.originalTarget = originalTarget
            self.parentTarget = nil
            self.chainDepth = 0
            
            var cp: Set<String> = []
            for parameter in pathParameters {
                precondition(!cp.contains(parameter), "路由\(String(describing: originalTarget))的path解析出包含相同的参数名称: \(parameter)")
                cp.insert(parameter)
            }
            
            subTargets = originalTarget.subTargets.compactMap({ try? FJRouteTarget.InnerTargetType(originalTarget: $0, parentTarget: self, chainDepth: chainDepth + 1) })
        }
        
        private init(originalTarget: any FJRouteTargetType, parentTarget: InnerTargetType, chainDepth: Int) throws {
            precondition(!originalTarget.path.path.isEmpty, "路由\(String(describing: originalTarget))的path不能为空")
            
            if originalTarget.path.path != "/" {
                precondition(!originalTarget.path.path.hasSuffix("/"), "除了最顶层的'/'路由外, 其它任何路由都不能以'/'结尾. 当前路由: \(String(describing: originalTarget))")
            }
            
            precondition(chainDepth <= 100, "⚠️\(String(describing: originalTarget))在整个路由链路中位置过深, 可能是子路由循环指向问题, 请仔细排查")
            
            (regExp, pathParameters) = try originalTarget.path.resolveRouteInfo()
            
            self.originalTarget = originalTarget
            self.parentTarget = parentTarget
            self.chainDepth = chainDepth
            
            var cp: Set<String> = []
            for parameter in pathParameters {
                precondition(!cp.contains(parameter), "路由\(String(describing: originalTarget))的path解析出包含相同的参数名称: \(parameter)")
                cp.insert(parameter)
            }
            
            var ppt: InnerTargetType? = parentTarget
            while let p = ppt {
                for pp in p.pathParameters {
                    precondition(!pathParameters.contains(pp), "在路由: \(String(describing: p.originalTarget))及其子路由: \(String(describing: originalTarget))中发现重复的路由参数: \(pp)")
                }
                ppt = p.parentTarget
            }
            
            var st: [InnerTargetType] = []
            for r in originalTarget.subTargets {
                if let srt = try? FJRouteTarget.InnerTargetType(originalTarget: r, parentTarget: parentTarget, chainDepth: chainDepth + 1) {
                    st.append(srt)
                }
            }
            subTargets = st
        }
    }
}

extension FJRouteTarget.InnerTargetType {
    
}
