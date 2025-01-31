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
public protocol FJRouterResourceable {
    /// 存放资源
    /// - Parameter resource: 资源
    ///
    /// 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...
    ///
    ///     let r1 = try FJRouterResource(path: "/intvalue1", value: { _ in 1 })
    ///     try await FJRouter.resource().put(r1)
    ///     let r2 = try FJRouterResource(path: "/intOptionalvalue1") { @Sendable info -> Int? in
    ///          return 1
    ///     }
    ///     try await FJRouter.resource().put(r2)
    ///     let r3 = try FJRouterResource(path: "/intOptionalvalue2") { @Sendable info -> Int? in
    ///         return nil
    ///     }
    ///     try await FJRouter.resource().put(r3)
    ///     let r4 = try FJRouterResource(path: "/stringvalue1", value: { _ in "haha" })
    ///     try await FJRouter.resource().put(r4)
    ///     let r5 = try FJRouterResource(path: "/intOptionalvalue3/:optional", value: { @Sendable info -> Int? in
    ///         let isOptional = info.pathParameters["optional"] == "1"
    ///         return isOptional ? nil : 1
    ///     })
    ///     try await FJRouter.resource().put(r5)
    ///     存放协议
    ///     let r6 = try FJRouterResource(path: "/protocolATest/:isA", value: { @Sendable info -> ATestable in
    ///          let isA = info.pathParameters["isA"] == "1"
    ///          return isA ? AModel() : BModel()
    ///     })
    ///     try await FJRouter.resource().put(r6)
    func put(_ resource: FJRouterResource) async throws
    
    /// 根据资源路径取对应资源
    ///
    ///     let intvalue1: Int = try await impl.get("/intvalue1", inMainActor: false)
    ///     let intvalue3: Int? = try await impl.get("/intvalue1", inMainActor: true)
    ///     let intOptionalvalue3: Int? = try await impl.get("/intOptionalvalue2", inMainActor: false)
    ///     let stringvalue1: String = try await impl.get("/stringvalue1", inMainActor: false)
    ///     let aTestable1: ATestable = try await impl.get("/protocolATest/1", inMainActor: false)
    ///     let aTestable2: ATestable = try await impl.get("/protocolATest/0", inMainActor: true)
    ///     let aTestable3: BModel = try await impl.get("/protocolATest/0", inMainActor: false)
    ///
    /// - Parameters:
    ///   - location: 资源路径
    ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
    /// - Returns: 对应资源
    func get<Value>(_ location: String, inMainActor mainActor: Bool) async throws -> Value where Value: Sendable
    
    /// 根据资源名称取对应资源
    /// - Parameters:
    ///   - name: 资源名称
    ///   - params: 资源path参数
    ///   - queryParams: 资源查询参数
    ///   - mainActor: 是否需要在主线程取. true: 强制主线程返回, false: 系统自动线程处理
    /// - Returns: 对应资源
    func get<Value>(name: String, params: [String : String], queryParams: [String : String], inMainActor mainActor: Bool) async throws -> Value where Value: Sendable
}
