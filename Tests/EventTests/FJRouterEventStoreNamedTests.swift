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
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a", name: "finda"))
        // 将下面注释打开, 会触发 "不能添加名称相同但path却不同的事件xxxxxx"的崩溃, 不用怀疑, 是正确的
//        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/c", name: "finda"))
    }
    
    @Test func testConvertWithNoParamsName() async throws {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a", name: "finda"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/b", name: nil))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "c", name: "findc"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/d/", name: "findd"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "e/", name: "finde"))
        
        let urla = try await store.convertLocationBy(name: "finda")
        #expect(urla == "/a")
        
        await #expect(throws: FJRouter.ConvertError.noExistName) {
            let _ = try await store.convertLocationBy(name: "findb")
        }
        
        let urlc = try await store.convertLocationBy(name: "findc")
        #expect(urlc == "c")
        
        let urld = try await store.convertLocationBy(name: "findd")
        #expect(urld == "/d/")
        
        let urle = try await store.convertLocationBy(name: "finde")
        #expect(urle == "e/")
        
        let urlap = try await store.convertLocationBy(name: "finda", params: ["id": "1"])
        #expect(urlap == "/a")
        
        let urldp = try await store.convertLocationBy(name: "findd", params: ["id": "1"])
        #expect(urldp == "/d/")
    }
    
    @Test func testConvertWithParamsName() async throws {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a/:id", name: "finda"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "c/:id", name: "findc"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/d/:id/", name: "findd"))
        
        let urla1 = try await store.convertLocationBy(name: "finda", params: ["id": "1"])
        #expect(urla1 == "/a/1")
        let urla2 = try await store.convertLocationBy(name: "finda", params: ["id": "1", "p": "q"])
        #expect(urla2 == "/a/1")
        let urla3 = try await store.convertLocationBy(name: "finda", params: ["pid": "1", "p": "q"])
        #expect(urla3 == "/a")
        let urla4 = try await store.convertLocationBy(name: "finda")
        #expect(urla4 == "/a")
        
        let urlc1 = try await store.convertLocationBy(name: "findc", params: ["id": "1"])
        #expect(urlc1 == "c/1")
        let urlc2 = try await store.convertLocationBy(name: "findc", params: ["id": "1", "p": "q"])
        #expect(urlc2 == "c/1")
        let urlc3 = try await store.convertLocationBy(name: "findc", params: ["pid": "1", "p": "q"])
        #expect(urlc3 == "c")
        let urlc4 = try await store.convertLocationBy(name: "findc")
        #expect(urlc4 == "c")
        
        let urld1 = try await store.convertLocationBy(name: "findd", params: ["id": "1"])
        #expect(urld1 == "/d/1/")
        let urld2 = try await store.convertLocationBy(name: "findd", params: ["id": "1", "p": "q"])
        #expect(urld2 == "/d/1/")
        let urld3 = try await store.convertLocationBy(name: "findd", params: ["pid": "1", "p": "q"])
        #expect(urld3 == "/d//")
    }
    
    @Test func testConvertWithQueryParamsName() async throws {
        let store = FJRouter.EventStore()
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/a", name: "finda"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/b", name: nil))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "c", name: "findc"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/d/", name: "findd"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "e/", name: "finde"))
        
//        let urla1 = try await store.convertLocationBy(name: "finda", queryParams: ["p": "q"])
//        #expect(urla1 == "/a?p=q")
//        
//        let urla2 = try await store.convertLocationBy(name: "finda", queryParams: ["p": "q", "r": "t"])
//        #expect(["/a?p=q&r=t", "/a?r=t&p=q"].contains(urla2))
//        
//        await #expect(throws: FJRouter.ConvertError.noExistName) {
//            let _ = try await store.convertLocationBy(name: "findb")
//        }
//        
//        let urlc = try await store.convertLocationBy(name: "findc", queryParams: ["p": "q"])
//        #expect(urlc == "c?p=q")
//        
//        let urld = try await store.convertLocationBy(name: "findd", queryParams: ["p": "q"])
//        #expect(urld == "/d/?p=q")
//        
//        let urle = try await store.convertLocationBy(name: "finde", queryParams: ["p": "q"])
//        #expect(urle == "e/?p=q")
        
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/user/:id", name: "finduser"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/books/:id/", name: "findbooks"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "pages/:id", name: "findpages"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "players/:id/", name: "findplayers"))
        await store.saveOrCreateListener(action: try FJRouterEventAction(path: "/tvs/:id/", name: "findtvs"))
        
        let users1 = try await store.convertLocationBy(name: "finduser", params: ["id": "1"], queryParams: ["age": "22"])
        #expect(users1 == "/user/1?age=22")
        let users2 = try await store.convertLocationBy(name: "finduser", queryParams: ["age": "22"])
        #expect(users2 == "/user/?age=22")
        
        let books1 = try await store.convertLocationBy(name: "findbooks", params: ["id": "1"], queryParams: ["age": "22"])
        #expect(books1 == "/books/1/?age=22")
        let books2 = try await store.convertLocationBy(name: "findbooks", queryParams: ["age": "22"])
        #expect(books2 == "/books//?age=22")
        
        let pages1 = try await store.convertLocationBy(name: "findpages", params: ["id": "1"], queryParams: ["age": "22"])
        #expect(pages1 == "pages/1?age=22")
        let pages2 = try await store.convertLocationBy(name: "findpages", queryParams: ["age": "22"])
        #expect(pages2 == "pages/?age=22")
        
        let players1 = try await store.convertLocationBy(name: "findplayers", params: ["id": "1"], queryParams: ["age": "22"])
        #expect(players1 == "players/1/?age=22")
        let players2 = try await store.convertLocationBy(name: "findplayers", queryParams: ["age": "22"])
        #expect(players2 == "players//?age=22")
        
        let tvs1 = try await store.convertLocationBy(name: "findtvs", params: ["id": "1"], queryParams: ["age": "22"])
        #expect(tvs1 == "/tvs/1/?age=22")
        let tvs2 = try await store.convertLocationBy(name: "findtvs", queryParams: ["age": "22"])
        #expect(tvs2 == "/tvs//?age=22")
    }
}
