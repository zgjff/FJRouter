//
//  URL+Extensions.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation

extension URL {
    var versionPath: String {
        if #available(iOS 16.0, *) {
            return path()
        } else {
            return path
        }
    }
}
