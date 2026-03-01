//
//  FJRouteMacro.swift
//  FJRouter
//
//  Created by zgjff on 2026/3/1.
//

@attached(extension, conformances: Equatable, Hashable, FJRouteTargetType, names: named(==), named(hash(into:)), arbitrary)
public macro FJRoute() = #externalMacro(module: "FJRouterMacros", type: "FJRouteMacroImpl")
