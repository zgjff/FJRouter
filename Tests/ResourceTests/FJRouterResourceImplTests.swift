import Testing
import Foundation
@testable import FJRouter

struct FJRouterResourceImplTests {
    let impl: FJRouterResourceable
    init() async throws {
        impl = FJRouter.ResourceImpl.clone()
        let r1 = try FJRouterResource(path: "/intvalue1", name: "intvalue1", value: { _ in 1 })
        try await impl.put(r1)
        let r2 = try FJRouterResource(path: "/intOptionalvalue1", name: "intOptionalvalue1") { @Sendable info -> Int? in
            return 1
        }
        try await impl.put(r2)
        let r3 = try FJRouterResource(path: "/intOptionalvalue2", name: "intOptionalvalue2") { @Sendable info -> Int? in
            return nil
        }
        try await impl.put(r3)
        let r4 = try FJRouterResource(path: "/stringvalue1", name: "stringvalue1", value: { _ in "haha" })
        try await impl.put(r4)
        let r5 = try FJRouterResource(path: "/intOptionalvalue3/:optional", name: "intOptionalvalue3", value: { @Sendable info -> Int? in
            let isOptional = info.pathParameters["optional"] == "1"
            return isOptional ? nil : 1
        })
        try await impl.put(r5)
        let r6 = try FJRouterResource(path: "/protocolATest/:isA", name: "protocolATest", value: { @Sendable info -> ATestable in
            let isA = info.pathParameters["isA"] == "1"
            return isA ? AModel() : BModel()
        })
        try await impl.put(r6)
    }
    
    @Test func putExist() async throws {
        await #expect(throws: FJRouter.PutResourceError.exist) {
            let r1 = try FJRouterResource(path: "/intvalue1", value: { _ in "haha" })
            try await impl.put(r1)
        }
        await #expect(throws: FJRouter.PutResourceError.exist) {
            let r2 = try FJRouterResource(path: "/intvalue1", name: "success", value: { _ in [1] })
            try await impl.put(r2)
        }
    }
    
    @Test func getNotNil() async throws {
        let intvalue1: Int = try await impl.get("/intvalue1", inMainActor: false)
        #expect(intvalue1 == 1)
        let intvalue2: Int = try await impl.get("/intvalue1", inMainActor: true)
        #expect(intvalue2 == 1)
        let intvalue3: Int? = try await impl.get("/intvalue1", inMainActor: true)
        #expect(intvalue3 == 1)
        let stringvalue1: String = try await impl.get("/stringvalue1", inMainActor: false)
        #expect(stringvalue1 == "haha")
        
        let aTestable1: ATestable = try await impl.get("/protocolATest/1", inMainActor: false)
        #expect(aTestable1.value == 3)
        
        let aTestable2: ATestable = try await impl.get("/protocolATest/0", inMainActor: true)
        #expect(aTestable2.value == 13)
        
        let aTestable3: BModel = try await impl.get("/protocolATest/0", inMainActor: false)
        #expect(aTestable3.value == 13)
    }
    
    @Test func getNil() async throws {
        let intOptionalvalue1: Int = try await impl.get("/intOptionalvalue1", inMainActor: false)
        #expect(intOptionalvalue1 == 1)
        let intOptionalvalue2: Int? = try await impl.get("/intOptionalvalue1", inMainActor: false)
        #expect(intOptionalvalue2 == 1)
        
        let intOptionalvalue3: Int? = try await impl.get("/intOptionalvalue2", inMainActor: false)
        #expect(intOptionalvalue3 == nil)
        
        let intOptionalvalue4: Int? = try await impl.get("/intOptionalvalue3/1", inMainActor: false)
        #expect(intOptionalvalue4 == nil)
        
        let intOptionalvalue5: Int? = try await impl.get("/intOptionalvalue3/0", inMainActor: false)
        #expect(intOptionalvalue5 == 1)
    }
    
    @Test func getValueTypeError() async throws {
        await #expect(throws: FJRouter.GetResourceError.valueType) {
            let _: String = try await impl.get("/intvalue1", inMainActor: false)
        }
        await #expect(throws: FJRouter.GetResourceError.valueType) {
            let _: Int = try await impl.get("/intOptionalvalue2", inMainActor: false)
        }
        await #expect(throws: FJRouter.GetResourceError.valueType) {
            let _: BModel = try await impl.get("/protocolATest/1", inMainActor: false)
        }
    }
    
    @Test func getValueByNameWithNoParams() async throws {
        let intvalue1: Int = try await impl.get(name: "intvalue1", params: [:], queryParams: [:], inMainActor: true)
        #expect(intvalue1 == 1)
        let intvalue11: Int = try await impl.get(name: "intvalue1", params: [:], queryParams: [:], inMainActor: false)
        #expect(intvalue11 == 1)
        
        let intOptionalvalue1: Int? = try await impl.get(name: "intOptionalvalue1", params: [:], queryParams: [:], inMainActor: true)
        #expect(intOptionalvalue1 == 1)
        let intOptionalvalue111: Int? = try await impl.get(name: "intOptionalvalue1", params: [:], queryParams: [:], inMainActor: false)
        #expect(intOptionalvalue111 == 1)
        
        let intOptionalvalue2: Int? = try await impl.get(name: "intOptionalvalue2", params: [:], queryParams: [:], inMainActor: true)
        #expect(intOptionalvalue2 == nil)
        let intOptionalvalue22: Int? = try await impl.get(name: "intOptionalvalue2", params: [:], queryParams: [:], inMainActor: false)
        #expect(intOptionalvalue22 == nil)
    }
    
    @Test func getValueByNameWithParams() async throws {
        let intOptionalvalue3: Int? = try await impl.get(name: "intOptionalvalue3", params: ["optional": "1"], queryParams: [:], inMainActor: true)
        #expect(intOptionalvalue3 == nil)
        
        let intOptionalvalue31: Int? = try await impl.get(name: "intOptionalvalue3", params: ["optional": "0"], queryParams: [:], inMainActor: false)
        #expect(intOptionalvalue31 == 1)
        
        let intOptionalvalue32: Int = try await impl.get(name: "intOptionalvalue3", params: ["optional": "0"], queryParams: [:], inMainActor: true)
        #expect(intOptionalvalue32 == 1)
        
        let protocolATest: ATestable = try await impl.get(name: "protocolATest", params: ["isA": "1"], queryParams: [:], inMainActor: true)
        #expect(protocolATest.value == 3)
        
        let protocolATest1: ATestable = try await impl.get(name: "protocolATest", params: ["isA": "0"], queryParams: [:], inMainActor: false)
        #expect(protocolATest1.value == 13)
    }
}


fileprivate protocol ATestable: Sendable {
    var value: Int { get set }
}

fileprivate struct AModel: ATestable {
    var value = 3
}

fileprivate struct BModel: ATestable {
    var value = 13
}
