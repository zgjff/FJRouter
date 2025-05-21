//
//  FJRouterResourceMatchInfo.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/28.
//

import Foundation

extension FJRouter {
    /// 资源匹配信息
    public struct ResourceMatchInfo: Sendable {
        /// 要匹配的原始url
        public let url: URL
        /// 匹配到的内容字符串
        public let matchedLocation: String
        /// 匹配到的资源
        public let resource: FJRouterResource
        /// 匹配到的参数
        public let pathParameters: [String: String]
        /// 匹配到的url query参数
        public let queryParameters: [String: String]
        
        init(
            url: URL,
            matchedLocation: String,
            resource: FJRouterResource,
            pathParameters: [String : String] = [:],
            queryParameters: [String : String] = [:]
        ) {
            self.url = url
            self.matchedLocation = matchedLocation
            self.resource = resource
            self.pathParameters = pathParameters
            self.queryParameters = queryParameters
        }
    }
}

extension FJRouter.ResourceMatchInfo: CustomStringConvertible, CustomDebugStringConvertible {
    public nonisolated var description: String {
        var result = "FJRouter.ResourceMatchInfo(url: \(url), resource: \(resource)"
        if !pathParameters.isEmpty {
            result.append(", pathParameters: \(pathParameters)")
        }
        if !queryParameters.isEmpty {
            result.append(", queryParameters: \(queryParameters)")
        }
        result += ")"
        return result
    }
    
    public var debugDescription: String {
        description
    }
}
