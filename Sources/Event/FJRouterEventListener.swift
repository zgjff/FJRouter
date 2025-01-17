//
//  FJRouterEventListener.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import Combine
extension FJRouter {
    internal struct EventListener: Sendable {
        let action: FJRouterEventAction
        private nonisolated(unsafe) let subject: PassthroughSubject<Void, Never>
        init(action: FJRouterEventAction) {
            self.action = action
            self.subject = PassthroughSubject()
        }
    }
}

extension FJRouter.EventListener {
    func publisher() -> AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func receive(value: FJRouter.EventMatchState) {
        
    }
}

extension FJRouter.EventListener: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(action)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.action == rhs.action
    }
}
