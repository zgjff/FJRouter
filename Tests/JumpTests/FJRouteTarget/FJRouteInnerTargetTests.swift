import Testing
import Foundation
import UIKit
@testable import FJRouter

struct FJRouteInnerTargetTests {
    @Test func testNoChildrenRoutePathParameters() async throws {
        let target = UserPageRoute.settings
        let innerTarget = FJRouteTarget.InnerTarget(target: target)
        let (_, pathParameters1, exists1) = try await innerTarget.resolve()
        #expect(pathParameters1.isEmpty)
        #expect(exists1 == false)
        let (_, pathParameters2, exists2) = try await innerTarget.resolve()
        #expect(pathParameters2.isEmpty)
        #expect(exists2 == true)
        
        let target2 = UserPageRoute.profile(id: "123")
        #expect(target2.pathParams["id"] == "123")
        
        let innerTarget2 = FJRouteTarget.InnerTarget(target: target2)
        let (_, pathParameters21, exists21) = try await innerTarget2.resolve()
        #expect(pathParameters21 == ["id"])
        #expect(exists21 == false)
        
        let (_, pathParameters22, exists22) = try await innerTarget2.resolve()
        #expect(pathParameters22 == ["id"])
        #expect(exists22 == true)
        
        let target3 = UserPageRoute.service(uid: "123", sid: "sdfui98")
        #expect(target3.pathParams["uid"] == "123")
        
        let innerTarget3 = FJRouteTarget.InnerTarget(target: target3)
        let (_, pathParameters31, _) = try await innerTarget3.resolve()
        #expect(pathParameters31 == ["uid", "sid"])
    }

    @Test func testNoChildrenRouteFullPath() async {
        let target1 = UserPageRoute.settings
        let innerTarget1 = FJRouteTarget.InnerTarget(target: target1)
        #expect(await innerTarget1.fullpath() == "/user/settings")
        
        let target2 = UserPageRoute.profile(id: "1")
        let innerTarget2 = FJRouteTarget.InnerTarget(target: target2)
        #expect(await innerTarget2.fullpath() == "/user/:id")
        
        let target3 = UserPageRoute.service(uid: "1", sid: "2")
        let innerTarget3 = FJRouteTarget.InnerTarget(target: target3)
        #expect(await innerTarget3.fullpath() == "/user/:uid/service/:sid")
    }
    
    @Test func testSubDepth1ChildrenRoutesPathParameters() async throws {
        let target1 = SettingsPageRoute.settings
        let innerTarget1 = FJRouteTarget.InnerTarget(target: target1)
        let (_, pathParameters1, _) = try await innerTarget1.resolve()
        #expect(pathParameters1.isEmpty)
        
        let target2 = SettingsPageRoute.app
        let innerTarget2 = FJRouteTarget.InnerTarget(target: target2)
        let (_, pathParameters2, _) = try await innerTarget2.resolve()
        #expect(pathParameters2.isEmpty)
        
        let target3 = SettingsPageRoute.user(id: "1")
        let innerTarget3 = FJRouteTarget.InnerTarget(target: target3)
        let (_, pathParameters3, _) = try await innerTarget3.resolve()
        #expect(pathParameters3 == ["id"])
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

fileprivate enum SettingsPageRoute: FJRouteTargetType {
    case settings
    case app
    case appfeature1
    case user(id: String)
    
    var path: String {
        switch self {
        case .settings:
            return "/settings"
        case .app:
            return "app"
        case .appfeature1:
            return "feature1"
        case .user:
            return "user/:id"
        }
    }
    
    var name: String? {
        switch self {
        case .settings:
            return "Settings"
        case .app:
            return "AppSettings"
        case .appfeature1:
            return "Appfeature1"
        case .user:
            return "UserSettings"
        }
    }
    
    var pathParams: [String : String] {
        switch self {
        case .settings, .app, .appfeature1:
            return [:]
        case .user(id: let id):
            return ["id": id]
        }
    }
    
    var subTargets: [any FJRouteTargetType] {
        switch self {
        case .settings:
            return [SettingsPageRoute.app, SettingsPageRoute.user(id: "0")]
        case .app:
            return [SettingsPageRoute.appfeature1]
        case .appfeature1:
            return []
        case .user:
            return []
        }
    }
    
    var builder: FJRouteTarget.Builder? {
        nil
    }
}
