//
//  FJPathUtils.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation

internal struct FJPathUtils: Sendable {
    internal static let `default` = FJPathUtils()
    private let parameterRegExp: NSRegularExpression
    private init() {
        parameterRegExp = try! NSRegularExpression(pattern: #":(\w+)(\((?:\\.|[^\\()])+\))?"#, options: [])
    }
}

extension FJPathUtils {
    internal func patternToRegExp(pattern: String) -> (reg: NSRegularExpression?, parameters: [String]) {
        let matchs = parameterRegExp.matches(in: pattern, options: .reportProgress, range: NSRange(location: 0, length: pattern.count))
        let pstart = pattern.startIndex
        var start = 0
        var buffer: String
        if #available(iOS 14.0, *) {
            buffer = String(unsafeUninitializedCapacity: pattern.count + 1, initializingUTF8With: { _ in 0 })
        } else {
            buffer = ""
        }
        buffer += "^"
        var parameters: [String] = []
        for match in matchs {
            if match.range.location > start {
                let startIdx = pattern.index(pstart, offsetBy: start)
                let endIdx = pattern.index(startIdx, offsetBy: match.range.location - start)
                buffer += NSRegularExpression.escapedPattern(for: String(describing: pattern[startIdx..<endIdx]))
            }
            let startIdx = pattern.index(pstart, offsetBy: match.range.location + 1)
            let endIdx = pattern.index(startIdx, offsetBy: match.range.length - 1)
            let name = String(describing: pattern[startIdx..<endIdx])
            parameters.append(name)
            buffer += "(?<\(name)>[^/]+)"
            start = match.range.location + match.range.length
        }
        if start < pattern.count {
            let startIdx = pattern.index(pstart, offsetBy: start)
            let endIdx = pattern.index(startIdx, offsetBy: pattern.count - start)
            buffer += NSRegularExpression.escapedPattern(for: String(describing: pattern[startIdx..<endIdx]))
        }
        if !pattern.hasSuffix("/") {
            buffer.append("(?=/|$)")
        }
        let exp = try? NSRegularExpression(pattern: buffer, options: [])
        return (exp, parameters)
    }
    
    internal func matchRegExpHasPrefix(_ loc: String, regExp: NSRegularExpression?) -> NSRegularExpression? {
        guard let regExp else {
            return nil
        }
        if regExp.firstMatch(in: loc, range: NSRange(location: 0, length: loc.count)) != nil {
            return regExp
        }
        let ploc = "/\(loc)"
        if regExp.firstMatch(in: ploc, range: NSRange(location: 0, length: ploc.count)) != nil {
            return regExp
        }
        return nil
    }
    
    /// 利用正则从字符串中提取参数并按照参数名进行映射
    internal func extractPathParameters(_ parameters: [String], inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        if parameters.isEmpty {
            return [:]
        }
        guard let regExp else {
            return [:]
        }
        let checkStrings = [string]
        var matchResults: [String] = []
        
        for cs in checkStrings {
            regExp.enumerateMatches(in: cs, options: [], range: NSRange(location: 0, length: cs.count)) { result, flags, _ in
                guard let result else {
                    return
                }
                let results = stride(from: 0, to: result.numberOfRanges, by: 1)
                    .map({ result.range(at: $0) })
                    .dropFirst()
                    .compactMap({ Range($0, in: cs) })
                    .compactMap { String(describing: cs[$0]) }
                matchResults += results
            }
            if !matchResults.isEmpty {
                return zip(parameters, matchResults).reduce([String: String](), { $0.merging([$1.0: $1.1]) { (_, new) in new } })
            }
        }
        return zip(parameters, matchResults).reduce([String: String](), { $0.merging([$1.0: $1.1]) { (_, new) in new } })
    }
    
    internal func convertNewUrlPath(from path: String, params: [String: String] = [:], queryParams: [String: String] = [:]) throws -> String {
        let newParams = params.reduce([String: String]()) { partialResult, pairs in
            var f = partialResult
            f.updateValue(pairs.value, forKey: pairs.key)
            return f
        }
        let location = FJPathUtils.default.patternToPath(pattern: path, pathParameters: newParams)
        var cop = URLComponents(string: location)
        if !queryParams.isEmpty {
            var queryItems = cop?.queryItems ?? []
            for qp in queryParams {
                queryItems.append(URLQueryItem(name: qp.key, value: qp.value))
            }
            cop?.queryItems = queryItems
        }
        guard let final = cop?.string else {
            throw FJRouter.ConvertError.urlConvert
        }
        guard final.count > 1 else {
            return final
        }
        if queryParams.isEmpty && path.hasSuffix("/") && !final.hasSuffix("/") {
            return final + "/"
        }
        if queryParams.isEmpty && !path.hasSuffix("/") && final.hasSuffix("/") {
            let result = final.dropLast()
            return String(result)
        }
        return final
    }
    
    internal func patternToPath(pattern: String, pathParameters parameters: [String: String]) -> String {
        var buffer: String
        if #available(iOS 14.0, *) {
            buffer = String(unsafeUninitializedCapacity: pattern.count, initializingUTF8With: { _ in 0 })
        } else {
            buffer = ""
        }
        let matchs = parameterRegExp.matches(in: pattern, options: .reportProgress, range: NSRange(location: 0, length: pattern.count))
        let pstart = pattern.startIndex
        var start = 0
        for match in matchs {
            if match.range.location > start {
                let startIdx = pattern.index(pstart, offsetBy: start)
                let endIdx = pattern.index(startIdx, offsetBy: match.range.location - start)
                buffer += String(describing: pattern[startIdx..<endIdx])
            }
            let startIdx = pattern.index(pstart, offsetBy: match.range.location + 1)
            let endIdx = pattern.index(startIdx, offsetBy: match.range.length - 1)
            let name = String(describing: pattern[startIdx..<endIdx])
            if let pn = parameters[name] {
                buffer += pn
            } else {
                //TODO: - throws error, 提醒缺少参数
            }
            start = match.range.location + match.range.length
        }
        if start < pattern.count {
            let startIdx = pattern.index(pstart, offsetBy: start)
            let endIdx = pattern.index(startIdx, offsetBy: pattern.count - start)
            buffer += String(describing: pattern[startIdx..<endIdx])
        }
        return buffer
    }
    
    internal func concatenatePaths(parentPath: String, childPath: String) -> String {
        var result = parentPath.split(separator: "/")
        result += childPath.split(separator: "/")
        var joinPath = result.filter { !$0.isEmpty }.joined(separator: "/")
        if joinPath.isEmpty {
            return "/"
        }
        if joinPath == "/" {
            return joinPath
        }
        let hasPrefixSlash = parentPath.hasPrefix("/") || childPath.hasPrefix("/")
        let hasSuffixSlash = ((parentPath != "/") || (parentPath != "/")) && (parentPath.hasSuffix("/") || childPath.hasSuffix("/"))
        if hasPrefixSlash && !joinPath.hasPrefix("/") {
            joinPath = "/" + joinPath
        }
        if hasSuffixSlash && !joinPath.hasSuffix("/") {
            joinPath = joinPath + "/"
        }
        return joinPath
    }
}
