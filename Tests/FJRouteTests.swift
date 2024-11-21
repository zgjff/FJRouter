import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouteTests {
    @Test func emptyPath() {
        #expect(throws: FJRoute.CreateError.emptyPath) {
            let _ = try FJRoute(path: "") { state in
                return UIViewController()
            }
        }
    }
    
    @Test func emptyName() {
        #expect(throws: FJRoute.CreateError.emptyName) {
            let _ = try FJRoute(path: "/", name: "") { state in
                return UIViewController()
            }
        }
    }
    
    @Test func noPageBuilder() {
        #expect(throws: FJRoute.CreateError.noPageBuilder) {
            let _ = try FJRoute(path: "/", builder: nil)
        }
    }
    
    @Test func matchRegExpAsPrefixWithoutParameter() {
        let pattern = "/settings/detail"
        let route = try! FJRoute(path: pattern) { state in
            return UIViewController()
        }
        
        #expect(route.matchRegExpHasPrefix("/settings/detail") != nil)
        #expect(route.matchRegExpHasPrefix("/settings/detail/abc") != nil)
        #expect(route.matchRegExpHasPrefix("settings/detail") != nil)
        #expect(route.matchRegExpHasPrefix("settings/detail/abc") != nil)
        
        #expect(route.matchRegExpHasPrefix("/settings/Detail") == nil)
        #expect(route.matchRegExpHasPrefix("/settings/details") == nil)
        #expect(route.matchRegExpHasPrefix("/settings") == nil)
        #expect(route.matchRegExpHasPrefix("/") == nil)
        #expect(route.matchRegExpHasPrefix("settings/Detail") == nil)
        #expect(route.matchRegExpHasPrefix("settings/details") == nil)
        #expect(route.matchRegExpHasPrefix("settings") == nil)
    }
}
