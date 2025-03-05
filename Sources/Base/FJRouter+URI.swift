//
//  File.swift
//  FJRouter
//
//  Created by zgjff on 2025/3/5.
//

import Foundation

extension FJRouter {
    /// 资源标识符
    public struct URI: Sendable {
        private let uri: PrivateURI
        
        private init(uri: PrivateURI) {
            self.uri = uri
        }
        
        /// 通过资源路径初始化
        /// - Parameter loc: 资源路径
        /// - Returns: uri
        public static func loc(_ loc: String) -> URI {
            .init(uri: .loc(loc))
        }
        
        /// 通过资源名称初始化
        /// - Parameters:
        ///   - name: 资源名称
        ///   - params: 资源参数
        ///   - queryParams: 资源查询参数
        /// - Returns: uri
        public static func name(_ name: String, params: [String : String] = [:], queryParams: [String : String] = [:]) -> URI {
            .init(uri: .name(name, params: params, queryParams: queryParams))
        }

        internal func finalLocation(transform: (_ name: String) -> String?) throws(FJRouter.ConvertError) -> String {
            switch uri {
            case .loc(let v):
                return v
            case let .name(name, params: params, queryParams: queryParams):
                let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let path = transform(n) else {
                    throw FJRouter.ConvertError.noExistName
                }
                return try FJPathUtils.default.convertNewUrlPath(from: path, params: params, queryParams: queryParams)
            }
        }
    }
}

extension FJRouter {
    /// 资源标识符
    public enum PrivateURI: @unchecked Sendable {
        /// 通过资源路径定位
        case loc(_ location: String)
        
        /// 通过资源名称+参数+查询参数定位
        ///
        ///    `params`参数和`queryParams`可以省略输入. eg:
        ///
        ///         let a: FJRouter.URI = .name("root")
        ///         let b: FJRouter.URI = .name("user", params: ["id": "1"])
        ///         let c: FJRouter.URI = .name("user", queryParams: ["name": "ha"])
        ///         let d: FJRouter.URI = .name("user", params: ["id": "1"], queryParams: ["name": "ha"])
        ///
        ///   - name: 路由名称
        ///   - params: 路由参数(可以省略)
        ///   - queryParams: 路由查询参数(可以省略)
        case name(_ name: String, params: [String : String] = [:], queryParams: [String : String] = [:])
    }
}
