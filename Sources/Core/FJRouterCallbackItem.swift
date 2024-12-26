//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2024/12/26.
//

import Foundation

extension FJRouter {
    /// 路由回调`name-value`
    public struct CallbackItem: Sendable {
        /// 名称
        public let name: String
        /// 内容
        public let value: (any Sendable)?

        public init?(name: String, value: (any Sendable)?) {
            let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if n.isEmpty {
                return nil
            }
            self.name = name
            self.value = value
        }
    }
}
