//
//  FJRouterActor.swift
//  FJRouter
//
//  Created by zgjff on 2025/12/26.
//

import Foundation

/// 路由全局actor
@globalActor public final actor FJRouterActor: GlobalActor {
    public typealias ActorType = FJRouterActor
    public static let shared = FJRouterActor()
    public nonisolated static var sharedUnownedExecutor: UnownedSerialExecutor {
        shared.unownedExecutor
    }
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        excutor.asUnownedSerialExecutor()
    }
    private let excutor: any SerialExecutor
    private init() {
        let queue = DispatchQueue(label: "com.RouteActorExcutor.FJRouter", qos: .userInitiated)
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            excutor = FJRouterExecutor(queue: queue)
        } else {
            excutor = FJRouterExecutorBelow17(queue: queue)
        }
    }
}

extension FJRouterActor {
    public static func run<T>(resultType: T.Type = T.self, body: @FJRouterActor @Sendable () throws -> T) async rethrows -> T where T : Sendable {
        return try await body()
    }
}

extension FJRouterActor {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    @available(iOS, introduced: 13.0, deprecated: 17.0, message: "Use FJRouterExecutor instead.")
    internal final class FJRouterExecutorBelow17: SerialExecutor {
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

extension FJRouterActor {
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    internal final class FJRouterExecutor: SerialExecutor, TaskExecutor {
        private let queue: DispatchQueue
        init(queue: DispatchQueue) {
            self.queue = queue
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
            let unownedJob = UnownedJob(job)
            queue.async {
                if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                    unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(), taskExecutor: self.asUnownedTaskExecutor())
                } else {
                    unownedJob.runSynchronously(on: self.asUnownedSerialExecutor())
                }
            }
        }
        
        @inlinable
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(ordinary: self)
        }
        
        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        @inlinable
        func asUnownedTaskExecutor() -> UnownedTaskExecutor {
            UnownedTaskExecutor(ordinary: self)
        }
    }
}
