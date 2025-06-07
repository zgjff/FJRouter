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
        /// - Parameter loc: 资源路径. 谨记, 如果注册资源路径中的path中含有参数, 必须在对应位置放入参数的值.
        ///     如果有查询参数, 请直接拼写在最后
        ///
        /// a注册的路由资源路径path中无参数, 可以直接传入对应的路径:
        ///
        ///      注册的路由FJRoute(path: "/intro", name: "AppIntro".....);
        ///     对应的标志符为: URI.loc("/intro"), 或者添加查询参数: URI.loc("/intro/query?q=a&p=b")
        ///
        /// b注册的路由资源路径path中有一个参数:
        ///
        ///     注册的路由FJRoute(path: "/users/:id", name: "fetchUser".....);
        ///     对应的标志符为: URI.loc("/users/5"), 即可解析id=5
        ///
        /// c注册的路由资源路径path中有多个参数:
        ///
        ///     注册的路由FJRoute(path: "/users/:uid/books/:bid", name: "FetchUserBook".....);
        ///     对应的标志符为: URI.loc("/users/5/books/175"), 即可解析uid=5, bid = 175
        ///
        /// - Returns: uri
        public static func loc(_ loc: String) -> URI {
            .init(uri: .loc(loc))
        }
        
        /// 通过资源名称初始化
        ///
        ///     注册的URI:
        ///     FJRoute(path: "/users/:id", name: "fetchUser".....)
        ///     let userUrl = URI.name("fetchUser", params: ["id": "1"])
        ///     此时 userUrl = "/users/1"
        ///     let userUrl = URI.name("fetchUser", params: ["id": "1"], queryParams: ["p": "a", "q": "b"])
        ///     此时 userUrl = "/users/1?p=a&q=b"
        ///
        /// - Parameters:
        ///   - name: 资源名称
        ///   - params: 资源参数: 注册资源路径中的path参数;
        ///
        ///         eg: 注册的路由资源路径path解析的参数
        ///         FJRoute(path: "/users/:id", name: "fetchUser".....),
        ///         在通过名称uri定位时, 需要传递`id`; 例如: URI.name("fetchUser", params: ["id": "3"])
        ///   - queryParams: 资源查询参数: 是url中的查询参数, 在iOS中的表现是`URLComponents`中的`queryItems`;
        ///
        ///         eg: https://cn.bing.com/search?q=URL&qs=n&form=b 中 `q=URL&qs=n&form=b`整串就是查询参数,
        ///         可以解析成iOS中的字典: `["q": "URL", "qs": "n", "foem": ""b]`
        /// - Returns: uri
        public static func name(_ name: String, params: [String : String] = [:], queryParams: [String : String] = [:]) -> URI {
            .init(uri: .name(name, params: params, queryParams: queryParams))
        }

        internal func finalLocation(in store: [String: String]) throws(FJRouter.ConvertError) -> String {
            switch uri {
            case .loc(let v):
                return v
            case let .name(name, params: params, queryParams: queryParams):
                let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let path = store[n] else {
                    throw FJRouter.ConvertError.noExistName
                }
                return try FJPathUtils.default.convertNewUrlPath(from: path, params: params, queryParams: queryParams)
            }
        }
    }
}

extension FJRouter {
    /// 资源标识符
    fileprivate enum PrivateURI: @unchecked Sendable {
        /// 通过资源路径定位
        case loc(_ location: String)
        
        /// 通过资源名称+参数+查询参数定位
        ///
        ///    `params`参数和`queryParams`可以省略输入. eg:
        ///
        ///         let a: FJRouter.PrivateURI = .name("root")
        ///         let b: FJRouter.PrivateURI = .name("user", params: ["id": "1"])
        ///         let c: FJRouter.PrivateURI = .name("user", queryParams: ["name": "ha"])
        ///         let d: FJRouter.PrivateURI = .name("user", params: ["id": "1"], queryParams: ["name": "ha"])
        ///
        ///   - name: 路由名称
        ///   - params: 路由参数(可以省略)
        ///   - queryParams: 路由查询参数(可以省略)
        case name(_ name: String, params: [String : String] = [:], queryParams: [String : String] = [:])
    }
}
