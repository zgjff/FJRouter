//
//  RouteUri.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/28.
//

@attached(peer, names: arbitrary)
public macro Uri(_ path: String) = #externalMacro(module: "FJRouterMacros", type: "RouteUri")
