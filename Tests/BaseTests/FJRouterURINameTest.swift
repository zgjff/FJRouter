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
    
    @Test mutating func missingParametersName() async throws {
        #expect(throws: FJRouter.ConvertError.missingParameters("id")) {
            let _ = try FJRouter.URI.name("user").finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("page")) {
            let _ = try FJRouter.URI.name("page").finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("id")) {
            let _ = try FJRouter.URI.name("book").finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("uid")) {
            let _ = try FJRouter.URI.name("detailUserBook").finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("bid")) {
            let _ = try FJRouter.URI.name("detailUserBook", params: ["uid": "1"]).finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("uid")) {
            let _ = try FJRouter.URI.name("detailUserBook", params: ["bid": "1"]).finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("id")) {
            let _ = try FJRouter.URI.name("userpage", params: [:]).finalLocation(in: self.store)
        }
        
        #expect(throws: FJRouter.ConvertError.missingParameters("query")) {
            let _ = try FJRouter.URI.name("userpage", params: ["id": "1"]).finalLocation(in: self.store)
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
        let loc1 = try FJRouter.URI.name("user", params: ["id": "123"]).finalLocation(in: self.store)
        #expect(loc1 == "/users/123")
        
        let loc2 = try FJRouter.URI.name("book", params: ["id": "789"]).finalLocation(in: self.store)
        #expect(loc2 == "/books/789")
        
        let loc3 = try FJRouter.URI.name("user", params: ["id": "123", "p": "q"]).finalLocation(in: self.store)
        #expect(loc3 == "/users/123")
    }
    
    @Test mutating func mutableParameter() async throws {
        let loc1 = try FJRouter.URI.name("detailUserBook", params: ["uid": "123", "bid": "789"]).finalLocation(in: self.store)
        #expect(loc1 == "/users/123/book/789")
        
        let loc2 = try FJRouter.URI.name("userpage", params: ["id": "123", "query": "a"]).finalLocation(in: self.store)
        #expect(loc2 == "/users/123/a")
        
        let loc3 = try FJRouter.URI.name("detailUserBook", params: ["uid": "123", "bid": "789", "p": "q"]).finalLocation(in: self.store)
        #expect(loc3 == "/users/123/book/789")
    }
    
    @Test mutating func queryParameter() async throws {
        let loc1 = try FJRouter.URI.name("app", queryParams: ["p": "q"]).finalLocation(in: store)
        #expect(loc1 == "/?p=q")
        
        let loc2 = try FJRouter.URI.name("tab", queryParams: ["p": "1", "q": "2"]).finalLocation(in: store)
        #expect(["/tab?p=1&q=2", "/tab?q=2&p=1"].contains(loc2))
        
        let loc3 = try FJRouter.URI.name("user", params: ["id": "123"], queryParams: ["p": "q"]).finalLocation(in: self.store)
        #expect(loc3 == "/users/123?p=q")
        
        let loc4 = try FJRouter.URI.name("detailUserBook", params: ["uid": "123", "bid": "789", "p": "q"], queryParams: ["p": "q"]).finalLocation(in: self.store)
        #expect(loc4 == "/users/123/book/789?p=q")
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
                "page": "/show/:page",
                "book": "/books/:id",
                "detailUserBook": "/users/:uid/book/:bid",
                "userpage": "/users/:id/:query"
            ]
            continuation.resume()
        }
    }
}
