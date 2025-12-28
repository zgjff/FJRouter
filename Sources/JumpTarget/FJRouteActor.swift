//
//  FJRouteActor.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

/// 路由全局actor
@globalActor public final actor FJRouteActor: GlobalActor {
    public typealias ActorType = FJRouteActor
    public static let shared = FJRouteActor()
    public nonisolated static var sharedUnownedExecutor: UnownedSerialExecutor {
        shared.unownedExecutor
    }
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        excutor.asUnownedSerialExecutor()
    }
    private let excutor: any SerialExecutor
    private init() {
        let queue = DispatchQueue(label: "com.RouteActorExcutor.FJRouter", qos: .userInitiated)
        if #available(iOS 17.0, *) {
            excutor = FJRouteExecutor(queue: queue)
        } else {
            excutor = FJRouteExecutorBelow17(queue: queue)
        }
    }
}

extension FJRouteActor {
    public static func run<T>(resultType: T.Type = T.self, body: @FJRouteActor @Sendable () throws -> T) async rethrows -> T where T : Sendable {
        return try await body()
    }
}

extension FJRouteActor {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    @available(iOS, introduced: 13.0, deprecated: 17.0, message: "Use FJRouteExecutor instead.")
    internal final class FJRouteExecutorBelow17: SerialExecutor {
        private let queue: DispatchQueue
        init(queue: DispatchQueue) {
            self.queue = queue
        }
        
        func enqueue(_ job: UnownedJob) {
            queue.async {
                job.runSynchronously(on: self.asUnownedSerialExecutor())
            }
        }
        
        @inlinable
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(ordinary: self)
        }
    }
}

extension FJRouteActor {
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    internal final class FJRouteExecutor: SerialExecutor, TaskExecutor {
        private let queue: DispatchQueue
        init(queue: DispatchQueue) {
            self.queue = queue
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
            let unownedJob = UnownedJob(job)
            print("enqueue----will enqueue:", Thread.current)
            queue.async {
                if #available(iOS 18.0, *) {
                    unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(), taskExecutor: self.asUnownedTaskExecutor())
                    print("enqueue----did run:", Thread.current)
                } else {
                    unownedJob.runSynchronously(on: self.asUnownedSerialExecutor())
                }
            }
        }
        
        @inlinable
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(ordinary: self)
        }
        
        @available(iOS 18.0, *)
        @inlinable
        func asUnownedTaskExecutor() -> UnownedTaskExecutor {
            UnownedTaskExecutor(ordinary: self)
        }
    }
}
