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

    func get<Value>(_ uri: FJRouter.URI, inMainActor mainActor: Bool) async throws(FJRouter.GetResourceError) -> Value where Value : Sendable {
        do {
            let loc = try await store.convertLocation(by: uri)
            guard let url = URL(string: loc) else {
                throw FJRouter.GetResourceError.errorLocUrl
            }
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
            if let err = error as? FJRouter.ConvertError {
                throw FJRouter.GetResourceError.convertNameLoc(err)
            }
            if let err = error as? FJRouter.GetResourceError {
                throw err
            }
            throw FJRouter.GetResourceError.notFind
        }
    }
    
    func update(_ uri: FJRouter.URI, value: @escaping FJRouterResource.Value) async throws(FJRouter.GetResourceError) {
        do {
            let loc = try await store.convertLocation(by: uri)
            guard let url = URL(string: loc) else {
                throw FJRouter.GetResourceError.notFind
            }
            try await store.update(url, value: value)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                if case .noExistName = err {
                    throw .notFind
                }
                if case .urlConvert = err {
                    throw .notFind
                }
                throw FJRouter.GetResourceError.convertNameLoc(err)
            }
            if let err = error as? FJRouter.GetResourceError {
                throw err
            }
            throw FJRouter.GetResourceError.notFind
        }
    }
    
    func delete(byPath path: String) async throws(FJRouter.GetResourceError) {
        try await store.deleteBy(path: path, name: nil)
    }
    
    func delete(byName name: String) async throws(FJRouter.GetResourceError) {
        try await store.deleteBy(path: nil, name: name)
    }
    
    func delete(_ uri: FJRouter.URI) async throws(FJRouter.GetResourceError) {
        do {
            let loc = try await store.convertLocation(by: uri)
            guard let url = URL(string: loc) else {
                throw FJRouter.GetResourceError.notFind
            }
            try await store.delete(url)
        } catch {
            if let err = error as? FJRouter.ConvertError {
                if case .noExistName = err {
                    throw .notFind
                }
                if case .urlConvert = err {
                    throw .notFind
                }
                throw FJRouter.GetResourceError.convertNameLoc(err)
            }
            if let err = error as? FJRouter.GetResourceError {
                throw err
            }
            throw FJRouter.GetResourceError.notFind
        }
    }
}
