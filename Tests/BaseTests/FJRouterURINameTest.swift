import Testing
import Foundation
@testable import FJRouter

struct FJRouterURINameTest {
    private lazy var store: [String: String] = [:]
    init() async {
        await configStore()
    }
    
    @Test func emptyStore() async throws {
        #expect(throws: FJRouter.ConvertError.noExistName) {
            let _ = try FJRouter.URI.name("a").finalLocation(in: [:])
        }
    }
    
    @Test mutating func noExistName() async throws {
        #expect(throws: FJRouter.ConvertError.noExistName) {
            let _ = try FJRouter.URI.name("a").finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.noExistName) {
            let _ = try FJRouter.URI.name("apps").finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.noExistName) {
            let _ = try FJRouter.URI.name("users").finalLocation(in: self.store)
        }
    }
    
    
    
    @Test mutating func noParameter() async throws {
        let loc1 = try FJRouter.URI.name("app").finalLocation(in: self.store)
        #expect(loc1 == "/")
        
        let loc2 = try FJRouter.URI.name("tab").finalLocation(in: self.store)
        #expect(loc2 == "/tab")
        
        let loc3 = try FJRouter.URI.name("login").finalLocation(in: self.store)
        #expect(loc3 == "/account/login")
        
        let loc4 = try FJRouter.URI.name("register").finalLocation(in: self.store)
        #expect(loc4 == "/account/register")
    }
    
    @Test mutating func oneParameter() async throws {
//        let loc1 = try FJRouter.URI.name("user").finalLocation(in: self.store)
//        #expect(loc1 == "/")
    }
}

private extension FJRouterURINameTest {
    mutating func configStore() async {
        await withCheckedContinuation { continuation in
            self.store = [
                "app": "/",
                "tab": "/tab",
                "user": "/users/:id",
                "login": "/account/login",
                "register": "/account/register",
                "page": "show/:page",
                "book": "books/:id",
                "detailUserBook": "/users/:uid/book/:bid",
                "userpage": "/users/:id/:query"
            ]
            continuation.resume()
        }
    }
}
