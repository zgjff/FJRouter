//
//  FJRouterResourceStore.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/27.
//

import Foundation

extension FJRouter {
    internal actor ResourceStore {
        private var nameToPath: [String: String] = [:]
        private var resources: Set<FJRouterResource> = []
    }
}

extension FJRouter.ResourceStore {
    func add(_ resource: FJRouterResource) throws(FJRouter.PutResourceError) {
        if resources.contains(resource) {
            throw FJRouter.PutResourceError.exist
        }
        resources.insert(resource)
        beginSaveResourceNamePath(resource)
    }
    
    func add(_ resource: FJRouterResource, uniquingPathWith combine: @Sendable (_ current: @escaping FJRouterResource.Value, _ new: @escaping FJRouterResource.Value) -> FJRouterResource.Value) {
        guard let oldResource = resources.first(where: { $0 == resource }) else {
            resources.insert(resource)
            beginSaveResourceNamePath(resource)
            return
        }
        if let name = oldResource.uri.name {
            nameToPath.removeValue(forKey: name)
        }
        // 存在
        let finalValue = combine(oldResource.value, resource.value)
        let newUri = resource.uri.chang(name: resource.uri.name ?? oldResource.uri.name)
        let finalResource = try! FJRouterResource(uri: newUri, value: finalValue)
        resources.update(with: finalResource)
        beginSaveResourceNamePath(finalResource)
    }
    
    func match(url: URL) throws(FJRouter.GetResourceError) -> FJRouter.ResourceMatchInfo {
        let fixUrl = url.fj.adjust()
        for resource in resources {
            if let info = findMatch(url: fixUrl, resource: resource) {
                return info
            }
        }
        throw FJRouter.GetResourceError.notFind
    }
    
    func convertLocation(by uri: FJRouter.URI) throws(FJRouter.ConvertError) -> String {
        try uri.finalLocation(in: nameToPath)
    }
    
    func update(_ url: URL, value: @escaping FJRouterResource.Value) throws(FJRouter.GetResourceError) {
        let oldResource = try match(url: url).resource
        let newResource = try! FJRouterResource(uri: oldResource.uri, value: value)
        resources.update(with: newResource)
    }
    
    func delete(_ url: URL) throws(FJRouter.GetResourceError) {
        let resource = try match(url: url).resource
        if let name = resource.uri.name {
            nameToPath.removeValue(forKey: name)
        }
        resources.remove(resource)
    }
    
    func deleteBy(path: String?, name: String?) throws(FJRouter.GetResourceError) {
        let resource: FJRouterResource?
        if let path {
            resource = resources.first(where: { $0.uri.path == path })
        } else if let name {
            resource = resources.first(where: { $0.uri.name == name })
        } else {
            resource = nil
        }
        guard let resource else {
            throw FJRouter.GetResourceError.notFind
        }
        if let name = resource.uri.name {
            nameToPath.removeValue(forKey: name)
        }
        resources.remove(resource)
    }
}

private extension FJRouter.ResourceStore {
    func beginSaveResourceNamePath(_ resource: FJRouterResource) {
        guard let name = resource.uri.name else {
            return
        }
        let fullPath = FJPathUtils.default.concatenatePaths(parentPath: "", childPath: resource.uri.path)
        if nameToPath.keys.contains(name) {
            let prefullpath = nameToPath[name]
            /// 提前崩溃, 防止这种错误出现
            assert(prefullpath == fullPath, "不能添加名称相同但path却不同的资源: name: \(name), newfullpath: \(fullPath), oldfullpath: \(String(describing: prefullpath))")
        }
        nameToPath.updateValue(fullPath, forKey: name)
    }
    
    func findMatch(url: URL, resource: FJRouterResource) -> FJRouter.ResourceMatchInfo? {
        guard let pairs = FJRouter.ResourceMatch.match(resource: resource, byUrl: url) else {
            return nil
        }
        return .init(url: url, matchedLocation: pairs.match.matchedLocation, resource: pairs.match.resource, pathParameters: pairs.pathParameters, queryParameters: url.fj.queryParams)
    }
}
