import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouterViewControllerTests {
    init() async {
        try? await registerRoutes()
    }
    
    @Test func testSearchSignleRoute() async throws {
        let vc1 = try await FJRouter.shared.viewController(forLocation: "/")
        #expect(vc1 is ViewControllerRoot)
        let vc2 = try await FJRouter.shared.viewController(forName: "root")
        #expect(vc2 is ViewControllerRoot)
    }
    
    @Test func testSearchSameRoutes() async throws {
        let vc1 = try await FJRouter.shared.viewController(forLocation: "/same")
        #expect(vc1 is ViewController1)
        let vc2 = try await FJRouter.shared.viewController(forName: "sameRouteForTest")
        #expect(vc2 is ViewController1)
        let vc3 = try await FJRouter.shared.viewController(forName: "sameRouteForTest1")
        #expect(vc3 is ViewController1)
    }
    
    @Test func testSearchDeepSignleRoute() async throws {
        let vc1 = try await FJRouter.shared.viewController(forLocation: "/book/feature1")
        #expect(vc1 is ViewControllerBook1)
        let vc2 = try await FJRouter.shared.viewController(forLocation: "/book/feature2")
        #expect(vc2 is ViewControllerBook2)
        let vc3 = try await FJRouter.shared.viewController(forName: "feature2")
        #expect(vc3 is ViewControllerBook2)
    }
    
    @Test func testSearchParamsRoute() async throws {
        let vc1 = try await FJRouter.shared.viewController(forLocation: "/play/123")
        #expect(vc1 is ViewControllerPlay)
    }
    
    @Test func testSearchDeepParamsRoute() async throws {
        let vc1 = try await FJRouter.shared.viewController(forLocation: "/play/123/feature1")
        #expect(vc1 is ViewControllerPlay1)
        let vc2 = try await FJRouter.shared.viewController(forLocation: "/play/123/feature4/haha")
        #expect(vc2 is ViewControllerPlay6)
        let vc3 = try await FJRouter.shared.viewController(forName: "feature4", params: ["id": "123", "name": "haha"])
        #expect(vc3 is ViewControllerPlay6)
    }
    
    @Test func testSearchDeepParamsSameRoute() async throws {
        let vc1 = try await FJRouter.shared.viewController(forLocation: "/play/123/feature3/haha")
        #expect(vc1 is ViewControllerPlay3)
        let vc2 = try await FJRouter.shared.viewController(forName: "bfeature3", params: ["id": "123"])
        #expect(vc2 is ViewControllerPlay4)
        let vc3 = try await FJRouter.shared.viewController(forName: "bfeature3-1", params: ["id": "123"])
        #expect(vc3 is ViewControllerPlay4)
    }
    
    @Test func testSearchErrorLocUrlError() async throws {
        await #expect(throws: FJRouter.MatchError.errorLocUrl) {
            try await FJRouter.shared.viewController(forLocation: "")
        }
    }
    
    @Test func testSearchNotFindError() async throws {
        await #expect(throws: FJRouter.MatchError.notFind) {
            try await FJRouter.shared.viewController(forLocation: "/sadfsadf")
        }
        await #expect(throws: FJRouter.MatchError.notFind) {
            try await FJRouter.shared.viewController(forLocation: "/play/123/feature4")
        }
    }
}

extension FJRouterViewControllerTests {
    fileprivate func registerRoutes() async throws {
        do {
            let route1 = try FJRoute(path: "/", name: "root", builder: { _ in ViewControllerRoot() })
            await FJRouter.shared.registerRoute(route1)
        }
        
        do {
            let route2 = try FJRoute(path: "/same", builder: { _ in ViewController1() })
            await FJRouter.shared.registerRoute(route2)
            let route3 = try FJRoute(path: "/same", name: "sameRouteForTest", builder: { _ in ViewController2() })
            await FJRouter.shared.registerRoute(route3)
            try await FJRouter.shared.registerRoute(path: "/same", builder: { _ in ViewController3() })
            try await FJRouter.shared.registerRoute(path: "/same", name: "sameRouteForTest1", builder: { _ in ViewController4() })
        }
        
        do {
            let route = try FJRoute(path: "/book", builder: ({ _  in ViewControllerBook() }), routes: [
                FJRoute(path: "feature1", builder: ({ _  in ViewControllerBook1() })),
                FJRoute(path: "feature2", name: "feature2", builder: ({ _  in ViewControllerBook2() })),
                FJRoute(path: "feature3", builder: ({ _  in ViewControllerBook3() })),
                FJRoute(path: "feature3", name: "feature3", builder: ({ _  in ViewControllerBook4() })),
                FJRoute(path: "feature3", name: "feature3-1", builder: ({ _  in ViewControllerBook5() })),
            ])
            await FJRouter.shared.registerRoute(route)
        }
        
        do {
            let route = try FJRoute(path: "/play/:id", builder: ({ _  in ViewControllerPlay() }), routes: [
                FJRoute(path: "feature1", builder: ({ _  in ViewControllerPlay1() })),
                FJRoute(path: "feature2", name: "bfeature2", builder: ({ _  in ViewControllerPlay2() })),
                FJRoute(path: "feature3/:name", builder: ({ _  in ViewControllerPlay3() })),
                FJRoute(path: "feature3", name: "bfeature3", builder: ({ _  in ViewControllerPlay4() })),
                FJRoute(path: "feature3", name: "bfeature3-1", builder: ({ _  in ViewControllerPlay5() })),
                FJRoute(path: "feature4/:name", name: "feature4", builder: ({ _  in ViewControllerPlay6() })),
            ])
            await FJRouter.shared.registerRoute(route)
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
