// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
/// 命名空间
public enum FJRouter {}

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
