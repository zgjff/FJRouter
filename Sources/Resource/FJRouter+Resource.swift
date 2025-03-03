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
/// 建议使用try FJRouterResource(path: "/xxx", name: "xxx", value: xxx), get(name: xxx)等方法进行相关操作。
///
/// 1: 当资源路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误
///
/// 2: 在实际app中, 资源的`URL`格式可能会随着时间而改变, 但是一般资源名称不会去更改
public protocol FJRouterResourceable {
    /// 存放资源
    /// 
    /// - Parameter resource: 资源
    ///
    /// 1: 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...
    ///
    /// 2: 如果已经存放过相同`path`的资源, 则会抛出`FJRouter.PutResourceError.exist`错误。
    ///
    /// 3: 适用于全局只会存放一次的资源: 如单例中或者/application didFinishLaunchingWithOptions中
    ///
    /// 4: 或者存放的资源内部具体的值是个固定值, 不会随着时间/操作更改
    ///
    /// 5: 如果每次存放资源可能会更改, 建议使用`put(_ resource: FJRouterResource, uniquingPathWith: xxx)`方法
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
    func put(_ resource: FJRouterResource) async throws(FJRouter.PutResourceError)
    
    /// 存放资源
    /// - Parameters:
    ///   - resource: 资源
    ///   - combine: 如果已经存放过相同path的资源, 使用合并相同资源的策略
    ///
    /// 1: 如果已经存放过相同`path`的资源, 不会抛出`FJRouter.PutResourceError.exist`错误, 会按照`combine`策略进行合并
    ///
    /// 2: 适用于可能多处/多处存放: 如某个viewController, 出现的时候才去存储资源, 但是因为viewController可能会多次进入,
    /// 而且每次存放的资源的具体值均不相同, 使用此方法可以有效的存储, 不会抛出`FJRouter.PutResourceError.exist`错误
    ///
    /// 3: 资源的名称会优先使用新的资源name, 如果新的资源name为nil, 才会使用旧资源name
    ///
    ///     await impl.put(r) { (currnet, _) in currnet }
    ///     await impl.put(r) { (_, new) in new }
    ///
    func put(_ resource: FJRouterResource, uniquingPathWith combine: @Sendable (_ current: @escaping FJRouterResource.Value, _ new: @escaping FJRouterResource.Value) -> FJRouterResource.Value) async
    
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
    func get<Value>(_ location: String, inMainActor mainActor: Bool) async throws(FJRouter.GetResourceError) -> Value where Value: Sendable
    
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
    func get<Value>(name: String, params: [String : String], queryParams: [String : String], inMainActor mainActor: Bool) async throws(FJRouter.GetResourceError) -> Value where Value: Sendable
    
    /// 根据资源路径更新已存放的资源
    ///
    /// 更新不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误
    ///
    /// - Parameters:
    ///   - path: 资源路径
    ///   - value: 资源的值
    ///
    ///         try await impl.update(byPath: "/sintvalue1", value: { _ in 39 })
    ///
    func update(byPath path: String, value: @escaping FJRouterResource.Value) async throws(FJRouter.GetResourceError)
    
    /// 根据资源名称更新已存放的资源
    ///
    /// 更新不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误
    ///
    /// - Parameters:
    ///   - name: 资源名称
    ///   - value: 资源的值
    ///
    ///         try await impl.update(byName: "sintvalue1", value: { _ in 66 })
    ///
    func update(byName name: String, value: @escaping FJRouterResource.Value) async throws(FJRouter.GetResourceError)
    
    /// 根据资源路径删除已存放的资源
    ///
    /// 删除不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误
    ///
    ///     try await FJRouter.resource().delete(byPath: "adfasdf")
    ///
    /// - Parameter path: 资源路径
    func delete(byPath path: String) async throws(FJRouter.GetResourceError)
    
    /// 根据资源名称删除已存放的资源
    ///
    /// 删除不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误
    ///
    ///     try await FJRouter.resource().delete(byName: "adfasdf")
    ///
    /// - Parameter name: 资源名称
    func delete(byName name: String) async throws(FJRouter.GetResourceError)
}

extension FJRouterResourceable {
    /// 根据资源名称参数取对应资源
    /// - Parameter params: 资源名称参数, 方便协议方法传递默认参数
    /// - Returns: 对应资源
    public func get<Value>(name params: FJRouter.GetResourceByNameParams) async throws(FJRouter.GetResourceError) -> Value where Value: Sendable {
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
