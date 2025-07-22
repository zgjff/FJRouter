//
//  FJRouterWrapper.swift
//  FJRouter
//
//  Created by zgjff on 2025/6/3.
//

import Foundation

extension FJRouter {
    public struct Wrapper<Object>: @unchecked Sendable {
        public private(set) var object: Object
        
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
