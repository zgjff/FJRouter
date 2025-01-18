//
//  FJRouterEventMatchInfo.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 事件匹配信息
    public struct EventMatchInfo: Sendable {
        /// 要匹配的原始url
        public let url: URL
        /// 匹配到的内容字符串
        public let matchedLocation: String
        /// 匹配到的事件
        internal let action: FJRouterEventAction
        /// 匹配到的参数
        public let pathParameters: [String: String]
        /// 匹配到的url query参数
        public let queryParameters: [String: String]
        /// 携带的额外内容
        public let extra: (any Sendable)?
        
        init(
            url: URL,
            matchedLocation: String,
            action: FJRouterEventAction,
            pathParameters: [String : String] = [:],
            queryParameters: [String : String] = [:],
            extra: (any Sendable)? = nil
        ) {
            self.url = url
            self.matchedLocation = matchedLocation
            self.action = action
            self.pathParameters = pathParameters
            self.queryParameters = queryParameters
            self.extra = extra
        }
    }
}
