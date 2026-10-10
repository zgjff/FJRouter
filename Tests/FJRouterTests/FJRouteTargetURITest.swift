import Foundation
import Testing
@testable import FJRouter

@Suite("FJRouteTargetURI test")
struct FJRouteTargetURITest {
    @Test("equtalPath test for caseSensitive = true") func equtalPathCaseSensitive() async {
        let uri1 = FJRouteTarget.CommonURI(path: "/user", caseSensitive: true, name: nil)
        let uri2 = FJRouteTarget.CommonURI(path: "/USER", caseSensitive: true, name: nil)
        let uri3 = FJRouteTarget.CommonURI(path: "/User", caseSensitive: true, name: nil)
        #expect(uri1.equtalPath(to: uri2))
        #expect(uri1.equtalPath(to: uri3))
        #expect(uri2.equtalPath(to: uri3))
        
        let uri4 = FJRouteTarget.CommonURI(path: "/user1", caseSensitive: true, name: nil)
        #expect(!uri1.equtalPath(to: uri4))
        
        let uri5 = FJRouteTarget.CommonURI(path: "/user/:id", caseSensitive: true, name: nil)
        let uri6 = FJRouteTarget.CommonURI(path: "/user/:Id", caseSensitive: true, name: nil)
        let uri7 = FJRouteTarget.CommonURI(path: "/User/:id", caseSensitive: true, name: nil)
        let uri8 = FJRouteTarget.CommonURI(path: "/User/:Id", caseSensitive: true, name: nil)
        #expect(uri5.equtalPath(to: uri6))
        #expect(uri5.equtalPath(to: uri7))
        #expect(uri5.equtalPath(to: uri8))
        #expect(uri6.equtalPath(to: uri7))
        #expect(uri6.equtalPath(to: uri8))
        #expect(uri7.equtalPath(to: uri8))
    }
    
    @Test("equtalPath test for caseSensitive = false") func equtalPathNoCaseSensitive() async {
        let uri1 = FJRouteTarget.CommonURI(path: "/user", caseSensitive: false, name: nil)
        let uri2 = FJRouteTarget.CommonURI(path: "/USER", caseSensitive: false, name: nil)
        let uri3 = FJRouteTarget.CommonURI(path: "/User", caseSensitive: false, name: nil)
        #expect(!uri1.equtalPath(to: uri2))
        #expect(!uri1.equtalPath(to: uri3))
        #expect(!uri2.equtalPath(to: uri3))
        
        let uri4 = FJRouteTarget.CommonURI(path: "/user1", caseSensitive: false, name: nil)
        #expect(!uri1.equtalPath(to: uri4))
        
        let uri5 = FJRouteTarget.CommonURI(path: "/user/:id", caseSensitive: false, name: nil)
        let uri6 = FJRouteTarget.CommonURI(path: "/user/:Id", caseSensitive: false, name: nil)
        let uri7 = FJRouteTarget.CommonURI(path: "/User/:id", caseSensitive: false, name: nil)
        let uri8 = FJRouteTarget.CommonURI(path: "/User/:Id", caseSensitive: false, name: nil)
        #expect(!uri5.equtalPath(to: uri6))
        #expect(!uri5.equtalPath(to: uri7))
        #expect(!uri5.equtalPath(to: uri8))
        #expect(!uri6.equtalPath(to: uri7))
        #expect(!uri6.equtalPath(to: uri8))
        #expect(!uri7.equtalPath(to: uri8))
    }
    
    @Test("equtalPath test for different caseSensitive") func equtalPathDifferentCaseSensitive() async {
        let uri1 = FJRouteTarget.CommonURI(path: "/user", caseSensitive: true, name: nil)
        let uri2 = FJRouteTarget.CommonURI(path: "/USER", caseSensitive: false, name: nil)
        let uri3 = FJRouteTarget.CommonURI(path: "/user", caseSensitive: false, name: nil)
        let uri4 = FJRouteTarget.CommonURI(path: "/User", caseSensitive: false, name: nil)
        #expect(uri1.equtalPath(to: uri2))
        #expect(uri1.equtalPath(to: uri3))
        #expect(uri1.equtalPath(to: uri4))
        
        let uri5 = FJRouteTarget.CommonURI(path: "/user", caseSensitive: false, name: nil)
        let uri6 = FJRouteTarget.CommonURI(path: "/USER", caseSensitive: true, name: nil)
        let uri7 = FJRouteTarget.CommonURI(path: "/user", caseSensitive: true, name: nil)
        let uri8 = FJRouteTarget.CommonURI(path: "/User", caseSensitive: true, name: nil)
        #expect(uri5.equtalPath(to: uri6))
        #expect(uri5.equtalPath(to: uri7))
        #expect(uri5.equtalPath(to: uri8))
        
        let uri9 = FJRouteTarget.CommonURI(path: "/user1", caseSensitive: false, name: nil)
        #expect(!uri1.equtalPath(to: uri9))
        
        let uri10 = FJRouteTarget.CommonURI(path: "/user/:id", caseSensitive: false, name: nil)
        #expect(!uri1.equtalPath(to: uri10))
        #expect(!uri5.equtalPath(to: uri10))
        
        let uri11 = FJRouteTarget.CommonURI(path: "/User/:id", caseSensitive: true, name: nil)
        let uri12 = FJRouteTarget.CommonURI(path: "/User/:Id", caseSensitive: true, name: nil)
        #expect(uri10.equtalPath(to: uri11))
        #expect(uri11.equtalPath(to: uri10))
        #expect(uri10.equtalPath(to: uri12))
        #expect(uri12.equtalPath(to: uri10))
    }
}
