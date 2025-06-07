import Testing
import Foundation
@testable import FJRouter

struct FJRouterEventStoreMatchTests {
    @Test func testDifferentActionCount() async throws {
        let store = try await createStore()
        await #expect(store.numbers() == 5)
    }
    
    @Test func testSameActionCount() async throws {
        let store = try await createStore()
        await #expect(store.numbers() == 5)
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a")))
        await #expect(store.numbers() == 5)
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "a")))
        await #expect(store.numbers() == 6)
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "a/")))
        await #expect(store.numbers() == 7)
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a/")))
        await #expect(store.numbers() == 8)
    }
    
    @Test func testMatchNotExistAction() async throws {
        let store = try await createStore()
        let paris1 = await store.match(url: URL(string: "sendSuccess")!, extra: nil)
        #expect(paris1 == nil)
        
        let paris2 = await store.match(url: URL(string: "/Details")!, extra: nil)
        #expect(paris2 == nil)
    }
    
    @Test func testMatchNoParameters() async throws {
        let store = try await createStore { store in
            await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "sendSuccess")))
            await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "sendFailure")))
        }
        
        let pairs1 = await store.match(url: URL(string: "/details")!, extra: nil)
        #expect(pairs1 != nil)
        
        let pairs2 = await store.match(url: URL(string: "sendSuccess")!, extra: nil)
        #expect(pairs2 != nil)
        
        let pairs3 = await store.match(url: URL(string: "sendFailure")!, extra: nil)
        #expect(pairs3 != nil)
        
        let pairs4 = await store.match(url: URL(string: "/details?p=q")!, extra: nil)
        #expect(pairs1 != nil)
        #expect(pairs4?.info.queryParameters == ["p": "q"])
        
        let pairs5 = await store.match(url: URL(string: "sendFailure?p=q&u=i")!, extra: nil)
        #expect(pairs5 != nil)
        #expect(pairs5?.info.queryParameters["p"] == "q")
        #expect(pairs5?.info.queryParameters["u"] == "i")
    }
    
    @Test func testMatchWithParameters() async throws {
        let store = try await createStore { store in
            await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/books/:bid/details/:page")))
        }
        
        let pairs1 = await store.match(url: URL(string: "/pages/123")!, extra: nil)
        #expect(pairs1?.info.pathParameters == ["id": "123"])
        
        let pairs2 = await store.match(url: URL(string: "/books/123/details/100")!, extra: nil)
        #expect(pairs2?.listener.action.uri.path == "/books/:bid/details/:page")
        #expect(pairs2?.info.pathParameters["bid"] == "123")
        #expect(pairs2?.info.pathParameters["page"] == "100")
        
        let pairs3 = await store.match(url: URL(string: "/books/123/details/100?q=p&u=i")!, extra: nil)
        #expect(pairs3?.listener.action.uri.path == "/books/:bid/details/:page")
        #expect(pairs3?.info.pathParameters["bid"] == "123")
        #expect(pairs3?.info.pathParameters["page"] == "100")
        #expect(pairs3?.info.queryParameters["q"] == "p")
        #expect(pairs3?.info.queryParameters["u"] == "i")
    }
}

extension FJRouterEventStoreMatchTests {
    fileprivate func createStore(action: ((_ store: FJRouter.EventStore) async throws -> ())? = nil) async throws -> FJRouter.EventStore {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/")))
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/a")))
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/details")))
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/pages/:id")))
        await store.saveOrCreateListener(action: try FJRouterEventAction(uri: FJRouterCommonRegisterURI(path: "/user/:id")))
        try await action?(store)
        return store
    }
}
