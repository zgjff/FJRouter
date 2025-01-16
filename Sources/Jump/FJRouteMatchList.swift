//
//  FJRouteMatchList.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation

struct FJRouteMatchList: @unchecked Sendable {
    /// 匹配结果
    let result: MatchResult
    /// 匹配的原始url
    let url: URL
    /// 匹配到的参数
    let pathParameters: [String: String]
    /// 携带的额外内容
    let extra: (any Sendable)?
    /// 与`url`匹配的完整路径
    let fullPath: String
    
    /// url中携带的query参数
    var queryParams: [String: String] {
        guard let cp = URLComponents(string: url.absoluteString) else {
            return [:]
        }
        let result = cp.queryItems?.reduce([String: String](), { partialResult, item in
            var result = partialResult
            if let v = item.value {
                result.updateValue(v, forKey: item.name)
            }
            return result
        })
        return result ?? [:]
    }
    
    /// 是否错误
    var isError: Bool {
        switch result {
        case .success(let array):
            return array.isEmpty
        case .error:
            return true
        }
    }
    
    var lastMatch: FJRouteMatch? {
        switch result {
        case .success(let array):
            return array.last
        case .error:
            return nil
        }
    }
    
    init(success: [FJRouteMatch], url: URL, pathParameters: [String : String], extra: (any Sendable)?) {
        result = .success(success)
        self.url = url
        self.pathParameters = pathParameters
        self.extra = extra
        
        var fullPath = ""
        for match in success {
            let pathSegment = match.route.path
            fullPath = FJPathUtils.default.concatenatePaths(parentPath: fullPath, childPath: pathSegment)
        }
        self.fullPath = fullPath
    }
    
    init(error: MatchError, url: URL, extra: (any Sendable)?) {
        result = .error(error)
        self.url = url
        self.extra = extra
        pathParameters = [:]
        fullPath = ""
    }
    
    func isSameOutExtra(with other: FJRouteMatchList) -> Bool {
        guard url == other.url else {
            return false
        }
        guard result == other.result else {
            return false
        }
        guard pathParameters == other.pathParameters else {
            return false
        }
        return true
    }
}

extension FJRouteMatchList: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch result {
        case .success(let values):
            return "FJRoute#success-->url:\(url),fullPath:\(fullPath),pathParameters:\(pathParameters),extra:\(String(describing: extra)),matches:\(values)"
        case .error(let err):
            return "FJRoute#error-->url:\(url),error:\(err)"
        }
    }
    
    var debugDescription: String {
        description
    }
}

extension FJRouteMatchList {
    /// 匹配结果
    enum MatchResult: Equatable, @unchecked Sendable {
        /// 成功
        case success([FJRouteMatch])
        /// 失败
        case error(MatchError)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.success(ls), .success(rs)):
                return ls == rs
            case let (.error(le), .error(re)):
                return le == re
            case (.success, .error), (.error, .success):
                return false
            }
        }
        
        var isEmpty: Bool {
            guard case .error(let matchError) = self, case .empty = matchError else {
                return false
            }
            return true
        }
        
        var isLoop: Bool {
            guard case .error(let matchError) = self, case .loopRedirect = matchError else {
                return false
            }
            return true
        }
        
        var isLimit: Bool {
            guard case .error(let matchError) = self, case .redirectLimit = matchError else {
                return false
            }
            return true
        }
    }
    
    enum MatchError: Error, Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
        /// 匹配为空
        case empty
        /// 重定向次数超出限制
        case redirectLimit(desc: String)
        /// 循环重定向
        case loopRedirect(desc: String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case let (.redirectLimit(desc: ld), .redirectLimit(desc: rd)):
                return ld == rd
            case let (.loopRedirect(desc: ld), .loopRedirect(desc: rd)):
                return ld == rd
            case (.empty, .redirectLimit), (.redirectLimit, .empty):
                return false
            case (.empty, .loopRedirect), (.loopRedirect, .empty):
                return false
            case (.redirectLimit, .loopRedirect), (.loopRedirect, .redirectLimit):
                return false
            }
        }
        
        var isEmpty: Bool {
            if case .empty = self {
                return true
            }
            return false
        }
        
        var isLoop: Bool {
            if case .loopRedirect = self {
                return true
            }
            return false
        }
        
        var isLimit: Bool {
            if case .redirectLimit = self {
                return true
            }
            return false
        }
        
        var description: String {
            switch self {
            case .empty:
                return "no routes"
            case .redirectLimit(let desc):
                return "too many redirects \(desc)"
            case .loopRedirect(let desc):
                return "redirect loop detected \(desc)"
            }
        }
        
        var debugDescription: String {
            description
        }
    }
}
