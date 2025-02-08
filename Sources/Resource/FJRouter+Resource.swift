//
//  FJRouter+Resource.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 资源中心
    public static func resource() -> any FJRouterResourceable {
        FJRouter.ResourceImpl.shared
    }
}

/// 资源中心协议
///
/// 建议使用try FJRouterResource(path: "/xxx", name: "xxx", value: xxx), get(name: xxx)方法进行相关操作。
///
/// 1: 当资源路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
///
/// 2: 在实际app中, 资源的`URL`格式可能会随着时间而改变, 但是一般资源名称不会去更改
public protocol FJRouterResourceable {
    /// 存放资源
    /// - Parameter resource: 资源
    ///
    /// 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...
    ///
    ///     let r1 = try FJRouterResource(path: "/intvalue1", name: "intvalue1", value: { _ in 1 })
    ///     try await FJRouter.resource().put(r1)
    ///     let r2 = try FJRouterResource(path: "/intOptionalvalue1", name: "intOptionalvalue1") { @Sendable info -> Int? in
    ///          return 1
    ///     }
    ///     try await FJRouter.resource().put(r2)
    ///     let r3 = try FJRouterResource(path: "/intOptionalvalue2", name: "intOptionalvalue2") { @Sendable info -> Int? in
    ///         return nil
    ///     }
    ///     try await FJRouter.resource().put(r3)
    ///     let r4 = try FJRouterResource(path: "/stringvalue1", name: "stringvalue1", value: { _ in "haha" })
    ///     try await FJRouter.resource().put(r4)
    ///     let r5 = try FJRouterResource(path: "/intOptionalvalue3/:optional", name: "intOptionalvalue3", value: { @Sendable info -> Int? in
    ///         let isOptional = info.pathParameters["optional"] == "1"
    ///         return isOptional ? nil : 1
    ///     })
    ///     try await FJRouter.resource().put(r5)
    ///     存放协议
    ///     let r6 = try FJRouterResource(path: "/protocolATest/:isA", name: "protocolATest", value: { @Sendable info -> ATestable in
    ///          let isA = info.pathParameters["isA"] == "1"
    ///          return isA ? AModel() : BModel()
    ///     })
    ///     try await FJRouter.resource().put(r6)
    ///
    func put(_ resource: FJRouterResource) async throws
    
    /// 根据资源路径取对应资源
    ///
    ///     let intvalue1: Int = try await FJRouter.resource().get("/intvalue1", inMainActor: false)
    ///     let intvalue3: Int? = try await FJRouter.resource().get("/intvalue1", inMainActor: true)
    ///     let intOptionalvalue3: Int? = try await FJRouter.resource().get("/intOptionalvalue2", inMainActor: false)
    ///     let stringvalue1: String = try await FJRouter.resource().get("/stringvalue1", inMainActor: false)
    ///     let aTestable1: ATestable = try await FJRouter.resource().get("/protocolATest/1", inMainActor: false)
    ///     let aTestable2: ATestable = try await FJRouter.resource().get("/protocolATest/0", inMainActor: true)
    ///     let aTestable3: BModel = try await FJRouter.resource().get("/protocolATest/0", inMainActor: false)
    ///
    /// - Parameters:
    ///   - location: 资源路径
    ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
    /// - Returns: 对应资源
    func get<Value>(_ location: String, inMainActor mainActor: Bool) async throws -> Value where Value: Sendable
    
    /// 根据资源名称取对应资源
    ///
    ///     let intvalue1: Int = try await FJRouter.resource().get(name: "intvalue1", params: [:], queryParams: [:], inMainActor: true)
    ///     let intvalue11: Int = try await FJRouter.resource().get(name: "intvalue1", params: [:], queryParams: [:], inMainActor: false)
    ///     let intOptionalvalue1: Int? = try await FJRouter.resource().get(name: "intOptionalvalue1", params: [:], queryParams: [:], inMainActor: true)
    ///     let intOptionalvalue3: Int? = try await FJRouter.resource().get(name: "intOptionalvalue3", params: ["optional": "1"], queryParams: [:], inMainActor: true)
    ///     let protocolATest1: ATestable = try await FJRouter.resource().get(name: "protocolATest", params: ["isA": "0"], queryParams: [:], inMainActor: false)
    ///
    /// - Parameters:
    ///   - name: 资源名称
    ///   - params: 资源path参数
    ///   - queryParams: 资源查询参数
    ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
    /// - Returns: 对应资源
    func get<Value>(name: String, params: [String : String], queryParams: [String : String], inMainActor mainActor: Bool) async throws -> Value where Value: Sendable
    
    /// 根据资源路径删除已存放的资源
    ///
    /// 删除不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误
    ///
    ///     try await FJRouter.resource().delete(byPath: "adfasdf")
    ///
    /// - Parameter path: 资源路径
    func delete(byPath path: String) async throws
    
    /// 根据资源名称删除已存放的资源
    ///
    /// 删除不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误
    ///
    ///     try await FJRouter.resource().delete(byName: "adfasdf")
    ///
    /// - Parameter name: 资源名称
    func delete(byName name: String) async throws
}

extension FJRouterResourceable {
    /// 根据资源名称参数取对应资源
    /// - Parameter params: 资源名称参数, 方便协议方法传递默认参数
    /// - Returns: 对应资源
    public func get<Value>(name params: FJRouter.GetResourceByNameParams) async throws -> Value where Value: Sendable {
        try await get(name: params.name, params: params.params, queryParams: params.queryParams, inMainActor: params.mainActor)
    }
}

extension FJRouter {
    /// 根据资源名称取对应资源: 方便协议方法传递默认参数
    public struct GetResourceByNameParams: Sendable {
        fileprivate let name: String
        fileprivate let params: [String : String]
        fileprivate let queryParams: [String : String]
        fileprivate let mainActor: Bool
        
        /// 初始化
        /// - Parameters:
        ///   - name: 资源名称
        ///   - params: 资源path参数
        ///   - queryParams: 资源查询参数
        ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
        public init(name: String, params: [String : String] = [:], queryParams: [String : String] = [:], inMainActor mainActor: Bool = true) {
            self.name = name
            self.params = params
            self.queryParams = queryParams
            self.mainActor = mainActor
        }
    }
}
