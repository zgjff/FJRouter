//
//  FJRouterResourceImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 事件总线
    internal final class ResourceImpl: Sendable {
        internal static let shared = ResourceImpl()
        private let store: ResourceStore
        private init() {
            store = ResourceStore()
        }
        
        /// for test
        internal static func clone() -> ResourceImpl {
            ResourceImpl()
        }
    }
}

extension FJRouter.ResourceImpl: FJRouterResourceable {
    func put(_ resource: FJRouterResource) async throws(FJRouter.PutResourceError) {
        try await store.add(resource)
    }
    
    func put(_ resource: FJRouterResource, uniquingPathWith combine: @Sendable (_ current: @escaping FJRouterResource.Value, _ new: @escaping FJRouterResource.Value) -> FJRouterResource.Value) async {
        await store.add(resource, uniquingPathWith: combine)
    }

    func get<Value>(_ location: String, inMainActor mainActor: Bool) async throws(FJRouter.GetResourceError) -> Value where Value : Sendable {
        guard let url = URL(string: location) else {
            throw FJRouter.GetResourceError.errorLocUrl
        }
        do {
            let info = try await store.match(url: url)
            if mainActor {
                let value = await MainActor.run {
                    return info.resource.value(info)
                }
                if let gvalue = value as? Value {
                    return gvalue
                }
                throw FJRouter.GetResourceError.valueType
            } else {
                let value = info.resource.value(info)
                if let gvalue = value as? Value {
                    return gvalue
                }
                throw FJRouter.GetResourceError.valueType
            }
        } catch {
            if let err = error as? FJRouter.GetResourceError {
                throw err
            }
            throw FJRouter.GetResourceError.notFind
        }
    }
    
    func get<Value>(name: String, params: [String : String], queryParams: [String : String], inMainActor mainActor: Bool) async throws(FJRouter.GetResourceError) -> Value where Value : Sendable {
        do {
            let loc =  try await store.convertLocationBy(name: name, params: params, queryParams: queryParams)
            return try await get(loc, inMainActor: mainActor)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.GetResourceError.convertNameLoc(err)
            } else if let err = error as? FJRouter.GetResourceError {
                throw err
            } else {
                throw FJRouter.GetResourceError.cancelled
            }
        }
    }
    
    func update(byPath path: String, value: @escaping FJRouterResource.Value) async throws(FJRouter.GetResourceError) {
        try await store.updateBy(path: path, name: nil, value: value)
    }
    
    func update(byName name: String, value: @escaping FJRouterResource.Value) async throws(FJRouter.GetResourceError) {
        try await store.updateBy(path: nil, name: name, value: value)
    }
    
    func delete(byPath path: String) async throws(FJRouter.GetResourceError) {
        try await store.deleteBy(path: path, name: nil)
    }
    
    func delete(byName name: String) async throws(FJRouter.GetResourceError) {
        try await store.deleteBy(path: nil, name: name)
    }
}
