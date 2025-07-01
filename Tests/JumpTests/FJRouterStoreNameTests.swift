import Testing
import  Foundation
import UIKit
@testable import FJRouter

struct FJRouterStoreNameTests {
    @Test func noParamsNames() async throws {
        let store = await createStore { store in
            let route = try! await FJRoute(path: "/", name: "home", builder: _builder, routes: await [
                FJRoute(path: "a", name: "namea", builder: _builder),
                FJRoute(path: "b", name: "nameb", builder: _builder),
                FJRoute(path: "c", name: "namec", builder: _builder),
            ])
            await store.addRoute(route)
        }
        let homeLoc = try await store.convertLocation(by: .name("home"))
        #expect(homeLoc == "/")
        let nameaLoc = try await store.convertLocation(by: .name("namea"))
        #expect(nameaLoc == "/a")
        let namebLoc = try await store.convertLocation(by: .name("nameb"))
        #expect(namebLoc == "/b")
        let namecLoc = try await store.convertLocation(by: .name("namec"))
        #expect(namecLoc == "/c")
        await #expect(throws: FJRouter.ConvertError.noExistName) {
            try await store.convertLocation(by: .name("named"))
        }
        
        let nameaOneQueryParamsLoc = try await store.convertLocation(by: .name("namea", queryParams: ["p": "1"]))
        #expect(nameaOneQueryParamsLoc == "/a?p=1")
        
        let nameaTwoQueryParamsLoc = try await store.convertLocation(by: .name("namea", queryParams: ["p": "1", "q": "2"]))
        #expect(["/a?p=1&q=2", "/a?q=2&p=1"].contains(nameaTwoQueryParamsLoc))
    }
    
    @Test func paramsNames() async throws {
        let store = await createStore { store in
            let route = try! await FJRoute(path: "/", name: "home", builder: _builder, routes: await [
                FJRoute(path: "settings/f1/:id", name: "settingsf1", builder: _builder),
            ])
            await store.addRoute(route)
        }
        
        let settingsf1Loc = try await store.convertLocation(by: .name("settingsf1", params: ["id": "123"]))
        #expect(settingsf1Loc == "/settings/f1/123")
        
        let settingsf1QPLoc = try await store.convertLocation(by: .name("settingsf1", params: ["id": "123"], queryParams: ["q1": "v1", "q2": "v2"]))
        #expect(["/settings/f1/123?q1=v1&q2=v2", "/settings/f1/123?q2=v2&q1=v1"].contains(settingsf1QPLoc))
    }
    
    @Test func childParamsNames() async throws {
        let store = await createStore { store in
            let route = try! await FJRoute(path: "/user/:id", name: "userInfo", builder: _builder, routes: await [
                FJRoute(path: "books", name: "userBooks", builder: _builder, routes: await [
                    FJRoute(path: ":bookId", name: "userBookInfo", builder: _builder)
                ]),
            ])
            await store.addRoute(route)
        }
        
        let userInfoLoc = try await store.convertLocation(by: .name("userInfo", params: ["id": "123"]))
        #expect(userInfoLoc == "/user/123")
        
        let userBooksLoc = try await store.convertLocation(by: .name("userBooks", params: ["id": "123"]))
        #expect(userBooksLoc == "/user/123/books")
        
        let userBookInfoLoc = try await store.convertLocation(by: .name( "userBookInfo", params: ["id": "123", "bookId": "78"]))
        #expect(userBookInfoLoc == "/user/123/books/78")
        
        let userBookInfoQPLoc = try await store.convertLocation(by: .name("userBookInfo", params: ["id": "123", "bookId": "78"], queryParams: ["q1": "v1", "q2": "v2"]))
        #expect(["/user/123/books/78?q1=v1&q2=v2", "/user/123/books/78?q2=v2&q1=v1"].contains(userBookInfoQPLoc))
    }
    
    @Test func sensitiveNames() async throws {
        let store = await createStore { store in
            let route = try! await FJRoute(path: "/", builder: _builder, routes: await [
                FJRoute(path: "a", name: "namea", builder: _builder),
                FJRoute(path: "b", name: "nameA", builder: _builder)
            ])
            await store.addRoute(route)
        }
        
        let nameaLoc = try await store.convertLocation(by: .name( "namea"))
        #expect(nameaLoc == "/a")
        
        let nameALoc = try await store.convertLocation(by: .name("nameA"))
        #expect(nameALoc == "/b")
    }
    
    fileprivate var _builder: FJRoute.Builder = { _ in
        return UIViewController()
    }
}

extension FJRouterStoreNameTests {
    fileprivate func createStore(action: (_ store: FJRouter.JumpStore) async -> ()) async -> FJRouter.JumpStore {
        let store = FJRouter.JumpStore()
        await action(store)
        return store
    }
}
