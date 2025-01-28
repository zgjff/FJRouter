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
    func add(_ resource: FJRouterResource) throws {
        if resources.contains(resource) {
            throw FJRouter.PutResourceError.exist
        }
        resources.insert(resource)
        beginSaveResourceNamePath(resource)
    }
    
    func match(url: URL) async throws -> FJRouter.ResourceMatchInfo {
        let fixUrl = url.adjust()
        for resource in resources {
            if let info = findMatch(url: fixUrl, resource: resource) {
                return info
            }
        }
        throw FJRouter.GetResourceError.notFind
    }
    
    func convertLocationBy(name: String, params: [String: String] = [:], queryParams: [String: String] = [:]) throws -> String {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let path = nameToPath[n] else {
            throw FJRouter.ConvertError.noExistName
        }
        return try FJPathUtils.default.convertNewUrlPath(from: path, params: params, queryParams: queryParams)
    }
}

private extension FJRouter.ResourceStore {
    func beginSaveResourceNamePath(_ resource: FJRouterResource) {
        guard let name = resource.name else {
            return
        }
        let fullPath = FJPathUtils.default.concatenatePaths(parentPath: "", childPath: resource.path)
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
        return .init(url: url, matchedLocation: pairs.match.matchedLocation, resource: pairs.match.resource, pathParameters: pairs.pathParameters, queryParameters: url.queryParams)
    }
}
