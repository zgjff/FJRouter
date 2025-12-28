// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
/// 命名空间
public enum FJRouter {}

/// 简洁命名空间: 用最少的单词调用对应api
///
/// 区别于`FJRouter`, 框架内很多class、enum、struct均属于`FJRouter`命名空间下;
/// 所以, 如果使用`FJRouter`时, 可能会有较多的干扰选择.
///
/// 路由跳转管理中心
/// FJ.jump 等同于 FJRouter.jump()
///
/// 事件总线管理中心
/// FJ.event 等同于 FJRouter.event()
///
/// 资源中心
/// FJ.resource 等同于 FJRouter.resource()
public enum FJ {}

extension FJ {
    @FJRouteActor public static func test() async -> Int {
//        print(123122, Thread.isMainThread, Thread.current.name)
        print("12312312")
        return 3
    }
    
    @FJRouteActor public static func test1() async -> Int {
//        print(123122, Thread.isMainThread, Thread.current.name)
        print("sdfsadf")
        return 5
    }
}

public actor AAA {
    private let executor: UnownedSerialExecutor
    public static func aaaa() async -> Int {
        MainActor.assertIsolated("sdfsdf")
        return 1
    }
    
    public init() {
        let queue = DispatchQueue(label: "com.RouteActorExcutor.FJRouter", qos: .userInitiated)
        if #available(iOS 17.0, *) {
            executor = FJRouteExecutor1(queue: queue).asUnownedSerialExecutor()
        } else {
            executor = FJRouteExecutorBelow171(queue: queue).asUnownedSerialExecutor()
        }
    }
    nonisolated public var unownedExecutor: UnownedSerialExecutor {
        executor
    }
}

extension AAA {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    @available(iOS, introduced: 13.0, deprecated: 17.0, message: "Use FJRouteExecutor instead.")
    fileprivate final class FJRouteExecutorBelow171: SerialExecutor {
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

extension AAA {
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    fileprivate final class FJRouteExecutor1: SerialExecutor {
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
        
        @inlinable func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(ordinary: self)
        }
    }
}
