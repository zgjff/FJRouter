import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouterViewControllerTests {
//    @Test func search
}

extension FJRouterViewControllerTests {
    fileprivate func createStore(action: (_ store: FJRouterStore) async throws -> ()) async rethrows -> FJRouterStore {
        let store = FJRouterStore()
        try await action(store)
        return store
    }
}

fileprivate final class ViewController1: UIViewController {}
fileprivate final class ViewController2: UIViewController {}
fileprivate final class ViewController3: UIViewController {}
fileprivate final class ViewController4: UIViewController {}
fileprivate final class ViewController5: UIViewController {}
fileprivate final class ViewController6: UIViewController {}
fileprivate final class ViewController7: UIViewController {}
