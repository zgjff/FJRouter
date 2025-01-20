//
//  FJRouterEventListener.swift
//  FJRouter
//
//  Created by zgjff on 2025/1/17.
//

import Foundation
import Combine
extension FJRouter {
    internal final class EventListener: Sendable {
        private(set) nonisolated(unsafe) var action: FJRouterEventAction
        private nonisolated(unsafe) let subject: PassthroughSubject<FJRouter.EventMatchInfo, Never>
        init(action: FJRouterEventAction) {
            self.action = action
            self.subject = PassthroughSubject()
        }
    }
}

extension FJRouter.EventListener {
    func publisher() -> AnyPublisher<FJRouter.EventMatchInfo, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func receive(value: FJRouter.EventMatchInfo) {
        subject.send(value)
    }
    
    func updateActionName(_ name: String) {
        guard let newAction = try? FJRouterEventAction(path: action.path, name: name) else {
            return
        }
        action = newAction
    }
}

extension FJRouter.EventListener: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(action)
    }
    
    static func == (lhs: FJRouter.EventListener, rhs: FJRouter.EventListener) -> Bool {
        lhs.action == rhs.action
    }
}

extension FJRouter.EventListener: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        "FJRouterEventListenerh#(action:\(action))"
    }
    
    var debugDescription: String {
        description
    }
}
