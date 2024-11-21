//
//  FJPathUtils.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import Foundation

internal struct FJPathUtils: @unchecked Sendable {
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
    
    /// 利用正则从字符串中提取参数并按照参数名进行映射
    internal func extractPathParameters(_ parameters: [String], inString string: String, useRegExp regExp: NSRegularExpression?) -> [String: String] {
        if parameters.isEmpty {
            return [:]
        }
        guard let regExp else {
            return [:]
        }
        var matchResults: [String] = []
        regExp.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: string.count)) { result, flags, _ in
            guard let result else {
                return
            }
            let results = stride(from: 0, to: result.numberOfRanges, by: 1)
                .map({ result.range(at: $0) })
                .dropFirst()
                .compactMap({ Range($0, in: string) })
                .compactMap { String(describing: string[$0]) }
            matchResults += results
        }
        return zip(parameters, matchResults).reduce([String: String](), { $0.merging([$1.0: $1.1]) { (_, new) in new } })
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
        return "/" + result.filter { !$0.isEmpty }.joined(separator: "/")
    }
}
