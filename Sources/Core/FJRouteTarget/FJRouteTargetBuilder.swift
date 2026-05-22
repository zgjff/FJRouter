//
//  FJRouteTargetBuilder.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

extension FJRouteTarget {
    /// 构建路由控制器
    public struct Builder: Sendable {
        private let builder: @MainActor @Sendable (_ info: BuilderInfo) -> IViewController
        public init(_ builder: @MainActor @Sendable @escaping (_ info: BuilderInfo) -> IViewController) {
            self.builder = builder
        }
    }
}
