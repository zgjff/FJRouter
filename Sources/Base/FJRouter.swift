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

extension FJRouter {
    public struct Wrapper<Object>: @unchecked Sendable {
        public let object: Object
        
        internal init(_ object: Object) {
            self.object = object
        }
    }
}

public protocol FJRouterWrapperValue {
    associatedtype WrapperObject
    var fj: FJRouter.Wrapper<WrapperObject> { get set }
}

extension FJRouterWrapperValue {
        public var fj: FJRouter.Wrapper<Self> {
            get { FJRouter.Wrapper(self) }
            set { }
        }
}

extension NSObject: FJRouterWrapperValue { }
