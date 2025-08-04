import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouteInnerTargetTests {
    @Test func testEmptyPathParameters() async throws {
        let target = UserPageRoute.settings
        let innerTarget = FJRouteTarget.InnerTarget(target: target)
        let (_, pathParameters1, exists1) = try await innerTarget.resolve()
        #expect(pathParameters1.isEmpty)
        #expect(exists1 == false)
        let (_, pathParameters2, exists2) = try await innerTarget.resolve()
        #expect(pathParameters2.isEmpty)
        #expect(exists2 == true)
    }
    
    @Test func testOnePathParameters() async throws {
        let target = UserPageRoute.profile(id: "123")
        #expect(target.pathParams["id"] == "123")
        
        let innerTarget = FJRouteTarget.InnerTarget(target: target)
        let (_, pathParameters1, exists1) = try await innerTarget.resolve()
        #expect(pathParameters1 == ["id"])
        #expect(exists1 == false)
        
        let (_, pathParameters2, exists2) = try await innerTarget.resolve()
        #expect(pathParameters2 == ["id"])
        #expect(exists2 == true)
    }
    
    @Test func testMoreThanOnePathParameters() async throws {
        let target = UserPageRoute.service(uid: "123", sid: "sdfui98")
        #expect(target.pathParams["uid"] == "123")
        
        let innerTarget = FJRouteTarget.InnerTarget(target: target)
        let (_, pathParameters1, _) = try await innerTarget.resolve()
        #expect(pathParameters1 == ["uid", "sid"])
    }
}

fileprivate enum UserPageRoute: FJRouteTargetType {
    case profile(id: String)
    case settings
    case service(uid: String, sid: String)
    
    var path: String {
        switch self {
        case .profile:
            return "/user/:id"
        case .settings:
            return "/user/settings"
        case .service:
            return "/user/:uid/service/:sid"
        }
    }
    
    var name: String? {
        switch self {
        case .profile:
            return "UserProfile"
        case .settings:
            return "UserSettings"
        case .service:
            return "UserService"
        }
    }
    
    var pathParams: [String : String] {
        switch self {
        case .profile(let id):
            return ["id": id]
        case .settings:
            return [:]
        case let .service(uid: uid, sid: sid):
            return ["uid": uid, "sid": sid]
        }
    }
    
    var builder: FJRouteTarget.Builder? {
        nil
    }
}
