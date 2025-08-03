//
//  FJRouteJumpProviderMatch.swift
//  FJRouter
//
//  Created by zgjff on 2025/8/3.
//

import Foundation

extension FJRouteJumpProvider {
    public struct MatchResult: Sendable {
        
        /// 携带的额外内容
        let extra: @Sendable () -> Any?
    }
}
