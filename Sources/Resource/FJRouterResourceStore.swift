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
        private var resources: Set<FJRouterResourceAction> = []
    }
}

extension FJRouter.ResourceStore {
    func add(_ resource: FJRouterResourceAction) {
//        guard let obj = listeners.first(where: { $0.action == action }) else {
//            let listener = FJRouter.EventListener(action: action)
//            listeners.insert(listener)
//            beginSaveActionNamePath(action: action)
//            return listener
//        }
//        guard let name = action.name else {
//            return obj
//        }
//        guard obj.action.name != nil else {
//            beginSaveActionNamePath(action: action)
//            obj.updateActionName(name)
//            return obj
//        }
//        beginSaveActionNamePath(action: action)
//        return obj
        guard let obj = resources.first(where: { $0 == resource }) else {
            resources.insert(resource)
            beginSaveResourceNamePath(resource)
            return
        }
        
    }
    
    func match(url: URL) async throws -> FJRouterResourceAction {
        throw FJRouter.JumpMatchError.errorLocUrl
    }
}

private extension FJRouter.ResourceStore {
    func beginSaveResourceNamePath(_ resource: FJRouterResourceAction) {
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
}
