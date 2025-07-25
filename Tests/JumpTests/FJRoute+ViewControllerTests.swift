import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouterViewControllerTests {
    init() async {
        try? await registerRoutes()
    }
    
    @Test func testSearchSignleRoute() async throws {
        let vc1 = try await FJRouter.jump().viewController(.loc("/"), extra: nil)
        #expect(vc1 is ViewControllerRoot)
        let vc2 = try await FJRouter.jump().viewController(.name("root"), extra: nil)
        #expect(vc2 is ViewControllerRoot)
    }
    
    @Test func testSearchSameRoutes() async throws {
        let vc1 = try await FJRouter.jump().viewController(.loc("/same"), extra: nil)
        #expect(vc1 is ViewController1)
        let vc2 = try await FJRouter.jump().viewController(.name("sameRouteForTest"), extra: nil)
        #expect(vc2 is ViewController1)
        let vc3 = try await FJRouter.jump().viewController(.name("sameRouteForTest1"), extra: nil)
        #expect(vc3 is ViewController1)
    }
    
    @Test func testSearchDeepSignleRoute() async throws {
        let vc1 = try await FJRouter.jump().viewController(.loc("/book/feature1"), extra: nil)
        #expect(vc1 is ViewControllerBook1)
        let vc2 = try await FJRouter.jump().viewController(.loc("/book/feature2"), extra: nil)
        #expect(vc2 is ViewControllerBook2)
        let vc3 = try await FJRouter.jump().viewController(.name("feature2"), extra: nil)
        #expect(vc3 is ViewControllerBook2)
    }
    
    @Test func testSearchParamsRoute() async throws {
        let vc1 = try await FJRouter.jump().viewController(.loc("/play/123"), extra: nil)
        #expect(vc1 is ViewControllerPlay)
    }
    
    @Test func testSearchDeepParamsRoute() async throws {
        let vc1 = try await FJRouter.jump().viewController(.loc("/play/123/feature1"), extra: nil)
        #expect(vc1 is ViewControllerPlay1)
        let vc2 = try await FJRouter.jump().viewController(.loc("/play/123/feature4/haha"), extra: nil)
        #expect(vc2 is ViewControllerPlay6)
        let vc3 = try await FJRouter.jump().viewController(.name("feature4", params: ["id": "123", "name": "haha"]), extra: nil)
        #expect(vc3 is ViewControllerPlay6)
    }
    
    @Test func testSearchDeepParamsSameRoute() async throws {
        let vc1 = try await FJRouter.jump().viewController(.loc("/play/123/feature3/haha"), extra: nil)
        #expect(vc1 is ViewControllerPlay3)
        let vc2 = try await FJRouter.jump().viewController(.name("bfeature3", params: ["id": "123"]), extra: nil)
        #expect(vc2 is ViewControllerPlay4)
        let vc3 = try await FJRouter.jump().viewController(.name("bfeature3-1", params: ["id": "123"]), extra: nil)
        #expect(vc3 is ViewControllerPlay4)
    }
    
    @Test func testSearchErrorLocUrlError() async throws {
        await #expect(throws: FJRouter.JumpMatchError.errorLocUrl) {
            try await FJRouter.jump().viewController(.loc(""), extra: nil)
        }
    }
    
    @Test func testSearchNotFindError() async throws {
        await #expect(throws: FJRouter.JumpMatchError.notFind) {
            try await FJRouter.jump().viewController(.loc("/sadfsadf"), extra: nil)
        }
        await #expect(throws: FJRouter.JumpMatchError.notFind) {
            try await FJRouter.jump().viewController(.loc("/play/123/feature4"), extra: nil)
        }
    }
}

extension FJRouterViewControllerTests {
    fileprivate func registerRoutes() async throws {
        do {
            let route1 = try await FJRoute(path: "/", name: "root", builder: { _ in ViewControllerRoot() })
            await FJRouter.jump().registerRoute(route1)
        }
        
        do {
            let route2 = try await FJRoute(path: "/same", builder: { _ in ViewController1() })
            await FJRouter.jump().registerRoute(route2)
            let route3 = try await FJRoute(path: "/same", name: "sameRouteForTest", builder: { _ in ViewController2() })
            await FJRouter.jump().registerRoute(route3)
            await FJRouter.jump().registerRoute(try FJRoute(path: "/same", builder: { _ in ViewController3() }))
            await FJRouter.jump().registerRoute(try FJRoute(path: "/same", name: "sameRouteForTest1", builder: { _ in ViewController4() }))
        }
        
        do {
            let route = try await FJRoute(path: "/book", builder: ({ _  in ViewControllerBook() }), routes: await [
                FJRoute(path: "feature1", builder: ({ _  in ViewControllerBook1() })),
                FJRoute(path: "feature2", name: "feature2", builder: ({ _  in ViewControllerBook2() })),
                FJRoute(path: "feature3", builder: ({ _  in ViewControllerBook3() })),
                FJRoute(path: "feature3", name: "feature3", builder: ({ _  in ViewControllerBook4() })),
                FJRoute(path: "feature3", name: "feature3-1", builder: ({ _  in ViewControllerBook5() })),
            ])
            await FJRouter.jump().registerRoute(route)
        }
        
        do {
            let route = try await FJRoute(path: "/play/:id", builder: ({ _  in ViewControllerPlay() }), routes: await [
                FJRoute(path: "feature1", builder: ({ _  in ViewControllerPlay1() })),
                FJRoute(path: "feature2", name: "bfeature2", builder: ({ _  in ViewControllerPlay2() })),
                FJRoute(path: "feature3/:name", builder: ({ _  in ViewControllerPlay3() })),
                FJRoute(path: "feature3", name: "bfeature3", builder: ({ _  in ViewControllerPlay4() })),
                FJRoute(path: "feature3", name: "bfeature3-1", builder: ({ _  in ViewControllerPlay5() })),
                FJRoute(path: "feature4/:name", name: "feature4", builder: ({ _  in ViewControllerPlay6() })),
            ])
            await FJRouter.jump().registerRoute(route)
        }
    }
}

fileprivate final class ViewControllerRoot: UIViewController {}
fileprivate final class ViewController1: UIViewController {}
fileprivate final class ViewController2: UIViewController {}
fileprivate final class ViewController3: UIViewController {}
fileprivate final class ViewController4: UIViewController {}
fileprivate final class ViewControllerBook: UIViewController {}
fileprivate final class ViewControllerBook1: UIViewController {}
fileprivate final class ViewControllerBook2: UIViewController {}
fileprivate final class ViewControllerBook3: UIViewController {}
fileprivate final class ViewControllerBook4: UIViewController {}
fileprivate final class ViewControllerBook5: UIViewController {}
fileprivate final class ViewControllerPlay: UIViewController {}
fileprivate final class ViewControllerPlay1: UIViewController {}
fileprivate final class ViewControllerPlay2: UIViewController {}
fileprivate final class ViewControllerPlay3: UIViewController {}
fileprivate final class ViewControllerPlay4: UIViewController {}
fileprivate final class ViewControllerPlay5: UIViewController {}
fileprivate final class ViewControllerPlay6: UIViewController {}
