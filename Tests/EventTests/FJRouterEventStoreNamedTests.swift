import Testing
import Foundation
@testable import FJRouter

struct FJRouterEventStoreNamedTests {
    @Test func testSaveName() async throws {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a", name: "finda"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/b", name: "findb"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/c", name: nil))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/d", name: "findd"))
        
        await #expect(store.numbers() == 4)
        
        let findA = await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a", name: "finda"))
        #expect(findA.action == (try! FJRouterEventAction(path: "/a", name: "finda")))
        
        let findc = await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/c", name: "findc"))
        await #expect(store.numbers() == 4)
        #expect(findc.action == (try! FJRouterEventAction(path: "/c", name: "findc")))
        
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/f", name: "findf"))
        await #expect(store.numbers() == 5)
    }
    
    @Test func testSaveSameNameDifferentPath() async throws {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a", name: "finda"))
        // 将下面注释打开, 会触发 "不能添加名称相同但path却不同的事件xxxxxx"的崩溃, 不用怀疑, 是正确的
//        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/c", name: "findb"))
    }
}
