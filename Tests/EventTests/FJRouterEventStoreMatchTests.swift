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
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a"))
        await #expect(store.numbers() == 5)
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "a"))
        await #expect(store.numbers() == 6)
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "a/"))
        await #expect(store.numbers() == 7)
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a/"))
        await #expect(store.numbers() == 8)
    }
}

extension FJRouterEventStoreMatchTests {
    fileprivate func createStore(action: ((_ store: FJRouter.EventStore) async throws -> ())? = nil) async throws -> FJRouter.EventStore {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/details"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/pages/:id"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/user/:id"))
        return store
    }
}
