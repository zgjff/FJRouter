//
//  FJRouterResourceImpl.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation

extension FJRouter {
    /// 事件总线
    internal struct ResourceImpl: Sendable {
        internal static let shared = ResourceImpl()
        private let store: ResourceStore
        private init() {
            store = ResourceStore()
        }
    }
}

extension FJRouter.ResourceImpl: FJRouterResourceable {
    func put(_ resource: FJRouterResourceAction) async {
        await store.add(resource)
    }
    
    func get<Value>(_ location: String, inMainActor mainActor: Bool) async throws -> Value? where Value : Sendable {
        do {
            let resource = try await store.match(url: URL(string: "/")!)
            if mainActor {
                return await MainActor.run {
                    if let rv = resource.value(1) as? Value {
                        return rv
                    } else {
                        return nil
                    }
                }
            } else {
                if let rv = resource.value(1) as? Value {
                    return rv
                } else {
                    return nil
                }
            }
        } catch {
            throw FJRouter.JumpMatchError.cancelled
        }
    }
    
    func get<Value>(name: String, params: [String : String], queryParams: [String : String], inMainActor mainActor: Bool) async throws -> Value? where Value : Sendable {
        nil
    }
}
