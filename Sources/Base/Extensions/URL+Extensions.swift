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
    
    func adjust() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        let cp = components.path
        if cp.isEmpty {
            components.path = "/"
        } else if cp.count > 1 && cp.hasSuffix("/") {
            let startIndex = cp.startIndex
            let endIndex = cp.index(cp.endIndex, offsetBy: -1)
            components.path = String(describing: cp[startIndex..<endIndex])
        }
        let newUrl = components.url ?? self
        return newUrl
    }
}
