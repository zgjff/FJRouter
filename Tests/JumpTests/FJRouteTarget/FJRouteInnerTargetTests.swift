import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouteInnerTargetTests {
    
}


fileprivate enum UserPageRoute: FJRouteTargetType {
    case profile(id: String)
    case settings
    
    var path: String {
        switch self {
        case .profile:
            return "/user/:id"
        case .settings:
            return "/user/settings"
        }
    }
    
    var name: String? {
        switch self {
        case .profile:
            return "UserProfile"
        case .settings:
            return "UserSettings"
        }
    }
    
    var pathParams: [String : String] {
        switch self {
        case .profile(let id):
            return ["id": id]
        case .settings:
            return [:]
        }
    }
    
    var builder: FJRouteTarget.Builder? {
        nil
    }
}
