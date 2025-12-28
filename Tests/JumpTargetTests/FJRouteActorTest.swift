import Testing
import Foundation
import OSLog
@testable import FJRouter

struct FJRouteActorTest {
    @Test func excuess() async throws {
        if #available(iOS 14.0, *) {
            let a = await AAA()
            await a.a()
            await a.b()
            await a.c()
        }
    }
}

@available(iOS 14.0, *)
@FJRouteActor private final class AAA: @unchecked Sendable {
    fileprivate let log = Logger(subsystem: "actor", category: "test")
    init() {
        
    }
    func a() {
        log.info("1: \(Thread.current)")
    }
    
    func b() {
        print(2, Thread.current)
    }
    
    func c() {
        print(3, Thread.current)
    }
}
