//
//  FJRouterMacroError.swift
//  FJRouter
//
//  Created by zgjff on 2026/2/28.
//

import Foundation

struct FJRouterMacroError: Error {
    let text: String
}

extension FJRouterMacroError: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        text
    }
    
    var debugDescription: String {
        text
    }
}
