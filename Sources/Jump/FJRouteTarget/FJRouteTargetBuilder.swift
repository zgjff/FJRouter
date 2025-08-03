//
//  FJRouteTargetBuilder.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation
import UIKit

extension FJRouteTarget {
    /// 构建路由控制器
    public struct Builder: Sendable {
        private let builder: @MainActor @Sendable (_ info: BuilderInfo) -> UIViewController
        public init(_ builder: @MainActor @Sendable @escaping (_ info: BuilderInfo) -> UIViewController) {
            self.builder = builder
        }
    }
}
