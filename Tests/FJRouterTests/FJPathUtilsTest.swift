import Foundation
import Testing
@testable import FJRouter

@Suite("path util analysis test")
struct FJPathUtilsTest {
    @Test func resolveNoPathParameterCaseInSensitivePattern() async throws {
        let pattern = "/settings/detail"
        let (reg, pathParameter) = try FJRouter.PathUtils.default.resolve(pattern: pattern, caseSensitive: false)
        #expect(pathParameter.isEmpty)
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail"))
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail/"))
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail/sdf"))
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail/search?id=3"))
        
        #expect(matchPathSuccess(regExp: reg, string: "/SettingS/Detail"))
        #expect(matchPathSuccess(regExp: reg, string: "/SETTINGS/DETAIL"))
        
        #expect(!matchPathSuccess(regExp: reg, string: "/settings/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings"))
        #expect(!matchPathSuccess(regExp: reg, string: "/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings/details"))
        #expect(!matchPathSuccess(regExp: reg, string: "/setting/detail"))
        
        #expect(!matchPathSuccess(regExp: reg, string: "/app/settings/detail"))
    }
    
    @Test func resolveNoPathParameterCaseSensitivePattern() async throws {
        let pattern = "/settings/detail"
        let (reg, pathParameter) = try FJRouter.PathUtils.default.resolve(pattern: pattern, caseSensitive: true)
        #expect(pathParameter.isEmpty)
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail"))
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail/"))
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail/sdf"))
        #expect(matchPathSuccess(regExp: reg, string: "/settings/detail/search?id=3"))
        
        #expect(!matchPathSuccess(regExp: reg, string: "/SettingS/Detail"))
        #expect(!matchPathSuccess(regExp: reg, string: "/SETTINGS/DETAIL"))
        
        #expect(!matchPathSuccess(regExp: reg, string: "/settings/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings"))
        #expect(!matchPathSuccess(regExp: reg, string: "/"))
        #expect(!matchPathSuccess(regExp: reg, string: "/settings/details"))
        #expect(!matchPathSuccess(regExp: reg, string: "/setting/detail"))
        
        #expect(!matchPathSuccess(regExp: reg, string: "/app/settings/detail"))
    }
    
    
}

extension FJPathUtilsTest {
    private func matchPathSuccess(regExp: NSRegularExpression, string: String) -> Bool {
        return regExp.numberOfMatches(in: string, options: [], range: NSRange(location: 0, length: string.count)) > 0
    }
}
