import Testing
import Foundation
@testable import FJRouter

struct FJPathUtilsTests {
    @Test func patternToRegExpWithoutParameter() async throws {
        let (reg, pathParameter) = try await FJPathUtils.default.patternToRegExp(pattern: "/settings/detail")
        #expect(pathParameter.isEmpty)
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings"))
        #expect(!matchPathSuccess(regExp: reg, string: "/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings/details"))
        #expect(!matchPathSuccess(regExp: reg, string: "/setting/detail"))
    }
    
    @Test func patternToRegExpWithParameter() async throws {
        let (reg, pathParameter) = try await FJPathUtils.default.patternToRegExp(pattern: "/user/:id/book/:bookId")
        #expect(pathParameter.count == 2)
        #expect(pathParameter[0] == "id")
        #expect(pathParameter[1] == "bookId")
        
        let string = "/user/123/book/456/18"
        let match = reg.firstMatch(in: string, range: NSRange(location: 0, length: string.count))
        #expect(match != nil)
        let parameterValues = FJPathUtils.default.extractPathParameters(pathParameter, inString: string, useRegExp: reg)
        #expect(parameterValues.count == 2)
        #expect(parameterValues[pathParameter[0]] == "123")
        #expect(parameterValues[pathParameter[1]] == "456")
        
        #expect(!matchPathSuccess(regExp: reg, string: "/user/123/book/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/user/123"))
        #expect(!matchPathSuccess(regExp: reg, string: "/user/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/"))
    }
    
    @Test func patternToPathWithoutParameter() async throws {
        let pattern = "/settings/detail"
        let (reg, pathParameter) = try await FJPathUtils.default.patternToRegExp(pattern: pattern)
        
        let url = "/settings/detail"
        let match = reg.firstMatch(in: url, range: NSRange(location: 0, length: url.count))
        #expect(match != nil)
        
        let parameterValues = FJPathUtils.default.extractPathParameters(pathParameter, inString: url, useRegExp: reg)
        let restoredUrl = try FJPathUtils.default.patternToPath(pattern: pattern, pathParameters: parameterValues)
        #expect(url == restoredUrl)
    }
    
    @Test func patternToPathWithParameter() async throws {
        let pattern = "/user/:id/book/:bookId"
        let (reg, pathParameter) = try await FJPathUtils.default.patternToRegExp(pattern: pattern)
        
        let url = "/user/123/book/456"
        let match = reg.firstMatch(in: url, range: NSRange(location: 0, length: url.count))
        #expect(match != nil)
        
        let parameterValues = FJPathUtils.default.extractPathParameters(pathParameter, inString: url, useRegExp: reg)
        let restoredUrl = try FJPathUtils.default.patternToPath(pattern: pattern, pathParameters: parameterValues)
        #expect(url == restoredUrl)
    }
    
    @Test func concatenatePaths() async throws {
        #expect(FJPathUtils.default.concatenatePaths(parentPath: "/a", childPath: "b/c") == "/a/b/c")
        #expect(FJPathUtils.default.concatenatePaths(parentPath: "/", childPath: "b") == "/b")
        #expect(FJPathUtils.default.concatenatePaths(parentPath: "/a", childPath: "/b/c/") == "/a/b/c/")
        #expect(FJPathUtils.default.concatenatePaths(parentPath: "/a", childPath: "b/c/") == "/a/b/c/")
        #expect(FJPathUtils.default.concatenatePaths(parentPath: "/", childPath: "/") == "/")
        #expect(FJPathUtils.default.concatenatePaths(parentPath: "", childPath: "") == "/")
    }
    
    private func matchPathSuccess(regExp: NSRegularExpression?, string: String) -> Bool {
        guard let regExp else {
            return false
        }
        return regExp.numberOfMatches(in: string, options: [], range: NSRange(location: 0, length: string.count)) > 0
    }
}
