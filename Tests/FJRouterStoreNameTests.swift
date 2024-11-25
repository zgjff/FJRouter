import Testing
import  Foundation
import UIKit
@testable import FJRouter

struct FJRouterStoreNameTests {
    @Test func noParamsNames() async throws {
        let store = await createStore { store in
            let route = try! FJRoute(path: "/", name: "home", builder: _builder, routes: [
                try! FJRoute(path: "a", name: "namea", builder: _builder),
                try! FJRoute(path: "b", name: "nameb", builder: _builder),
                try! FJRoute(path: "c", name: "namec", builder: _builder),
            ])
            await store.addRoute(route)
        }
        let homeLoc = await store.convertLocationBy(name: "home")
        #expect(homeLoc == "/")
        let nameaLoc = await store.convertLocationBy(name: "namea")
        #expect(nameaLoc == "/a")
        let namebLoc = await store.convertLocationBy(name: "nameb")
        #expect(namebLoc == "/b")
        let namecLoc = await store.convertLocationBy(name: "namec")
        #expect(namecLoc == "/c")
        let namedLoc = await store.convertLocationBy(name: "named")
        #expect(namedLoc == nil)
        
        let nameaOneQueryParamsLoc = await store.convertLocationBy(name: "namea", queryParams: ["p": "1"])
        #expect(nameaOneQueryParamsLoc == "/a?p=1")
        
        let nameaTwoQueryParamsLoc = await store.convertLocationBy(name: "namea", queryParams: ["p": "1", "q": "2"])
        #expect(["/a?p=1&q=2", "/a?q=2&p=1"].contains(nameaTwoQueryParamsLoc))
    }
    
    @Test func paramsNames() async throws {
        let store = await createStore { store in
            let route = try! FJRoute(path: "/", name: "home", builder: _builder, routes: [
                try! FJRoute(path: "settings/f1/:id", name: "settingsf1", builder: _builder),
            ])
            await store.addRoute(route)
        }
        
        let settingsf1Loc = await store.convertLocationBy(name: "settingsf1", params: ["id": "123"])
        #expect(settingsf1Loc == "/settings/f1/123")
        
        let settingsf1QPLoc = await store.convertLocationBy(name: "settingsf1", params: ["id": "123"], queryParams: ["q1": "v1", "q2": "v2"])
        #expect(["/settings/f1/123?q1=v1&q2=v2", "/settings/f1/123?q2=v2&q1=v1"].contains(settingsf1QPLoc))
    }
    
    @Test func childParamsNames() async throws {
        let store = await createStore { store in
            let route = try! FJRoute(path: "/user/:id", name: "userInfo", builder: _builder, routes: [
                try! FJRoute(path: "books", name: "userBooks", builder: _builder, routes: [
                    try! FJRoute(path: ":bookId", name: "userBookInfo", builder: _builder)
                ]),
            ])
            await store.addRoute(route)
        }
        
        let userInfoLoc = await store.convertLocationBy(name: "userInfo", params: ["id": "123"])
        #expect(userInfoLoc == "/user/123")
        
        let userBooksLoc = await store.convertLocationBy(name: "userBooks", params: ["id": "123"])
        #expect(userBooksLoc == "/user/123/books")
        
        let userBookInfoLoc = await store.convertLocationBy(name: "userBookInfo", params: ["id": "123", "bookId": "78"])
        #expect(userBookInfoLoc == "/user/123/books/78")
        
        let userBookInfoQPLoc = await store.convertLocationBy(name: "userBookInfo", params: ["id": "123", "bookId": "78"], queryParams: ["q1": "v1", "q2": "v2"])
        #expect(["/user/123/books/78?q1=v1&q2=v2", "/user/123/books/78?q2=v2&q1=v1"].contains(userBookInfoQPLoc))
    }
    
    @Test func sensitiveNames() async throws {
        let store = await createStore { store in
            let route = try! FJRoute(path: "/", builder: _builder, routes: [
                try! FJRoute(path: "a", name: "namea", builder: _builder),
                try! FJRoute(path: "b", name: "nameA", builder: _builder)
            ])
            await store.addRoute(route)
        }
        
        let nameaLoc = await store.convertLocationBy(name: "namea")
        #expect(nameaLoc == "/a")
        
        let nameALoc = await store.convertLocationBy(name: "nameA")
        #expect(nameALoc == "/b")
    }
    
    fileprivate var _builder: (@MainActor (_ state: FJRouterState) -> UIViewController) = { _ in
        return UIViewController()
    }
}

extension FJRouterStoreNameTests {
    fileprivate func createStore(action: (_ store: FJRouterStore) async -> ()) async -> FJRouterStore {
        let store = FJRouterStore()
        await action(store)
        return store
    }
}