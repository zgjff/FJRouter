//
//  FJRouteMacro.swift
//  FJRouter
//
//  Created by zgjff on 2026/3/1.
//
import FJRouter

@attached(extension, conformances: Equatable, Hashable, FJRouteTargetType, names: named(==), named(hash(into:)), arbitrary)
public macro FJRoute() = #externalMacro(module: "FJRouterMacroPlugins", type: "FJRouteMacroImpl")
