//
//  FJRouteActor.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation
/// 路由actor
@globalActor final actor FJRouteActor: GlobalActor {
    typealias ActorType = FJRouteActor
    static let shared = FJRouteActor()
    nonisolated static let sharedUnownedExecutor: UnownedSerialExecutor = shared.unownedExecutor
    nonisolated let unownedExecutor: UnownedSerialExecutor
    private init() {
        let queue = DispatchQueue(label: "com.RouteActorExcutor.FJRouter", qos: .userInitiated)
        if #available(iOS 17.0, *) {
            unownedExecutor = FJRouteExecutor(queue: queue).asUnownedSerialExecutor()
        } else {
            unownedExecutor = FJRouteExecutorBelow17(queue: queue).asUnownedSerialExecutor()
        }
    }
}

extension FJRouteActor {
    static func run<T>(resultType: T.Type = T.self, body: @FJRouteActor @Sendable () throws -> T) async rethrows -> T where T : Sendable {
        return try await body()
    }
}

extension FJRouteActor {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    @available(iOS, introduced: 13.0, deprecated: 17.0, message: "Use FJRouteExecutor instead.")
    fileprivate final class FJRouteExecutorBelow17: SerialExecutor {
        private let queue: DispatchQueue
        init(queue: DispatchQueue) {
            self.queue = queue
        }
        
        func enqueue(_ job: UnownedJob) {
            queue.async {
                job.runSynchronously(on: self.asUnownedSerialExecutor())
            }
        }
        
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(ordinary: self)
        }
    }
}

extension FJRouteActor {
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    fileprivate final class FJRouteExecutor: SerialExecutor {
        private let queue: DispatchQueue
        init(queue: DispatchQueue) {
            self.queue = queue
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
            let unownedJob = UnownedJob(job)
            queue.async {
                unownedJob.runSynchronously(on: self.asUnownedSerialExecutor())
            }
        }
        
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(ordinary: self)
        }
    }
}
