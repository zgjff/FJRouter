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

    @Test func deleteNotExist() async throws {
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.delete(byName: "")
        }
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.delete(byName: "adfasdf")
        }
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.delete(byPath: "")
        }
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.delete(byPath: "adfasdf")
        }
    }
    
    @Test func deleteExist() async throws {
        let r1 = try FJRouterResource(path: "/intvalue11", name: "intvalue11", value: { _ in 1 })
        try await impl.put(r1)
        let intvalue1: Int = try await impl.get("/intvalue11", inMainActor: false)
        #expect(intvalue1 == 1)
        try await impl.delete(byPath: "/intvalue11")
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            let _: Int = try await impl.get("/intvalue11", inMainActor: false)
        }
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.delete(byPath: "/intvalue11")
        }
        
        let r2 = try FJRouterResource(path: "/intOptionalvalue11", name: "intOptionalvalue11") { @Sendable info -> Int? in
            return 1
        }
        try await impl.put(r2)
        
        let intOptionalvalue1: Int? = try await impl.get(name: "intOptionalvalue11", params: [:], queryParams: [:], inMainActor: true)
        #expect(intOptionalvalue1 == 1)
        try await impl.delete(byName: "intOptionalvalue11")
        await #expect(throws: FJRouter.GetResourceError.convertNameLoc(.noExistName)) {
            let _: Int? = try await impl.get(name: "intOptionalvalue11", params: [:], queryParams: [:], inMainActor: true)
        }
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.delete(byName: "intOptionalvalue11")
        }
    }
    
    @Test func putUniquing() async throws {
        let intvalue1: Int = try await impl.get("/intvalue1", inMainActor: false)
        #expect(intvalue1 == 1)
        
        let r2 = try FJRouterResource(path: "/intvalue1", name: "intvalue1", value: { _ in 2 })
        await impl.put(r2) { (_, new) in new }
        let intvalue11: Int = try await impl.get("/intvalue1", inMainActor: false)
        #expect(intvalue11 == 2)
        
        let r3 = try FJRouterResource(path: "/intvalue1", name: "intvalue1", value: { _ in 11 })
        await impl.put(r3) { (current, _) in current }
        let intvalue111: Int = try await impl.get("/intvalue1", inMainActor: false)
        #expect(intvalue111 == 2)
        
        let r4 = try FJRouterResource(path: "/intvalue/first", name: nil, value: { _ in 12 })
        await impl.put(r4) { (_, new) in new }
        let intvaluefirst: Int = try await impl.get("/intvalue/first", inMainActor: false)
        #expect(intvaluefirst == 12)
        
        let r5 = try FJRouterResource(path: "/intvalue/second", name: nil, value: { _ in -2 })
        await impl.put(r5) { (currnet, _) in currnet }
        let intvaluesecond: Int = try await impl.get("/intvalue/second", inMainActor: false)
        #expect(intvaluesecond == -2)
        
        let r6 = try FJRouterResource(path: "/intvalue/second", name: "intvaluesecond", value: { _ in -12 })
        await impl.put(r6) { (currnet, _) in currnet }
        let intvaluesecond1: Int = try await impl.get(name: "intvaluesecond", params: [:], queryParams: [:], inMainActor: true)
        #expect(intvaluesecond1 == -2)
        
        let r7 = try FJRouterResource(path: "/intvalue/second", name: "intvaluesecond2", value: { _ in -12 })
        await impl.put(r7) { (currnet, _) in currnet }
        let intvaluesecond2: Int = try await impl.get(name: "intvaluesecond2", params: [:], queryParams: [:], inMainActor: true)
        #expect(intvaluesecond2 == -2)
        
        let r8 = try FJRouterResource(path: "/intvalue/second", name: "intvaluesecond3", value: { _ in -18 })
        await impl.put(r8) { (_, new) in new }
        let intvaluesecond3: Int = try await impl.get(name: "intvaluesecond3", params: [:], queryParams: [:], inMainActor: true)
        #expect(intvaluesecond3 == -18)
    }
    
    @Test func update() async throws {
        let r1 = try FJRouterResource(path: "/sintvalue1", name: "sintvalue1", value: { _ in 29 })
        try await impl.put(r1)
        let sintvalue1: Int = try await impl.get("/sintvalue1", inMainActor: false)
        #expect(sintvalue1 == 29)
        try await impl.update(byPath: "/sintvalue1", value: { _ in 39 })
        let sintvalue2: Int = try await impl.get("/sintvalue1", inMainActor: false)
        #expect(sintvalue2 == 39)
        try await impl.update(byName: "sintvalue1", value: { _ in 66 })
        let sintvalue3: Int = try await impl.get("/sintvalue1", inMainActor: false)
        #expect(sintvalue3 == 66)
        
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.update(byName: "sdfsadfsdaf", value: { _ in 66 })
        }
        await #expect(throws: FJRouter.GetResourceError.notFind) {
            try await impl.update(byPath: "/sdfsdfsadfsdaf", value: { _ in 66 })
        }
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
