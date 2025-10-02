import Testing
import Foundation
import MCP
@testable import TechConfMCP

@Suite("Value Conversion Tests")
struct ValueConversionTests {
    
    @Test("Convert string to Value")
    func testConvertString() {
        let value = Value.from("Hello, World!")
        
        if case .string(let str) = value {
            #expect(str == "Hello, World!")
        } else {
            Issue.record("Expected string value")
        }
    }
    
    @Test("Convert int to Value")
    func testConvertInt() {
        let value = Value.from(42)
        
        if case .int(let num) = value {
            #expect(num == 42)
        } else {
            Issue.record("Expected int value")
        }
    }
    
    @Test("Convert double to Value")
    func testConvertDouble() {
        let value = Value.from(3.14159)
        
        if case .double(let num) = value {
            #expect(num == 3.14159)
        } else {
            Issue.record("Expected double value")
        }
    }
    
    @Test("Convert bool to Value")
    func testConvertBool() {
        let value = Value.from(true)
        
        if case .bool(let flag) = value {
            #expect(flag == true)
        } else {
            Issue.record("Expected bool value")
        }
    }
    
    @Test("Convert array to Value")
    func testConvertArray() {
        let array: [Any] = ["Hello", 42, true]
        let value = Value.from(array)
        
        if case .array(let arr) = value {
            #expect(arr.count == 3)
            
            if case .string(let str) = arr[0] {
                #expect(str == "Hello")
            } else {
                Issue.record("Expected string at index 0")
            }
            
            if case .int(let num) = arr[1] {
                #expect(num == 42)
            } else {
                Issue.record("Expected int at index 1")
            }
            
            if case .bool(let flag) = arr[2] {
                #expect(flag == true)
            } else {
                Issue.record("Expected bool at index 2")
            }
        } else {
            Issue.record("Expected array value")
        }
    }
    
    @Test("Convert dictionary to Value")
    func testConvertDictionary() {
        let dict: [String: Any] = [
            "name": "John Doe",
            "age": 30,
            "active": true
        ]
        let value = Value.from(dict)
        
        if case .object(let obj) = value {
            #expect(obj.count == 3)
            
            if case .string(let name) = obj["name"]! {
                #expect(name == "John Doe")
            } else {
                Issue.record("Expected string for name")
            }
            
            if case .int(let age) = obj["age"]! {
                #expect(age == 30)
            } else {
                Issue.record("Expected int for age")
            }
            
            if case .bool(let active) = obj["active"]! {
                #expect(active == true)
            } else {
                Issue.record("Expected bool for active")
            }
        } else {
            Issue.record("Expected object value")
        }
    }
    
    @Test("Convert nested structures to Value")
    func testConvertNestedStructures() {
        let nested: [String: Any] = [
            "user": [
                "name": "Jane",
                "tags": ["swift", "ios"]
            ] as [String: Any],
            "count": 5
        ]
        
        let value = Value.from(nested)
        
        if case .object(let obj) = value {
            #expect(obj.count == 2)
            
            if case .object(let user) = obj["user"]! {
                if case .string(let name) = user["name"]! {
                    #expect(name == "Jane")
                }
                
                if case .array(let tags) = user["tags"]! {
                    #expect(tags.count == 2)
                }
            }
            
            if case .int(let count) = obj["count"]! {
                #expect(count == 5)
            }
        } else {
            Issue.record("Expected object value")
        }
    }
    
    @Test("Convert empty array to Value")
    func testConvertEmptyArray() {
        let array: [Any] = []
        let value = Value.from(array)
        
        if case .array(let arr) = value {
            #expect(arr.isEmpty)
        } else {
            Issue.record("Expected array value")
        }
    }
    
    @Test("Convert empty dictionary to Value")
    func testConvertEmptyDictionary() {
        let dict: [String: Any] = [:]
        let value = Value.from(dict)
        
        if case .object(let obj) = value {
            #expect(obj.isEmpty)
        } else {
            Issue.record("Expected object value")
        }
    }
}

@Suite("Value to JSON Conversion Tests")
struct ValueToJSONTests {
    
    @Test("String Value to JSON")
    func testStringToJSON() {
        let value = Value.string("test")
        let json = value.toJSONObject()
        
        #expect(json as? String == "test")
    }
    
    @Test("Int Value to JSON")
    func testIntToJSON() {
        let value = Value.int(42)
        let json = value.toJSONObject()
        
        #expect(json as? Int == 42)
    }
    
    @Test("Double Value to JSON")
    func testDoubleToJSON() {
        let value = Value.double(3.14)
        let json = value.toJSONObject()
        
        #expect(json as? Double == 3.14)
    }
    
    @Test("Bool Value to JSON")
    func testBoolToJSON() {
        let value = Value.bool(true)
        let json = value.toJSONObject()
        
        #expect(json as? Bool == true)
    }
    
    @Test("Null Value to JSON")
    func testNullToJSON() {
        let value = Value.null
        let json = value.toJSONObject()
        
        #expect(json is NSNull)
    }
    
    @Test("Array Value to JSON")
    func testArrayToJSON() {
        let value = Value.array([
            .string("hello"),
            .int(42),
            .bool(true)
        ])
        
        let json = value.toJSONObject()
        
        guard let array = json as? [Any] else {
            Issue.record("Expected array")
            return
        }
        
        #expect(array.count == 3)
        #expect(array[0] as? String == "hello")
        #expect(array[1] as? Int == 42)
        #expect(array[2] as? Bool == true)
    }
    
    @Test("Object Value to JSON")
    func testObjectToJSON() {
        let value = Value.object([
            "name": .string("John"),
            "age": .int(30),
            "active": .bool(true)
        ])
        
        let json = value.toJSONObject()
        
        guard let dict = json as? [String: Any] else {
            Issue.record("Expected dictionary")
            return
        }
        
        #expect(dict.count == 3)
        #expect(dict["name"] as? String == "John")
        #expect(dict["age"] as? Int == 30)
        #expect(dict["active"] as? Bool == true)
    }
    
    @Test("Nested structures to JSON")
    func testNestedToJSON() {
        let value = Value.object([
            "user": .object([
                "name": .string("Jane"),
                "tags": .array([.string("swift"), .string("ios")])
            ]),
            "count": .int(5)
        ])
        
        let json = value.toJSONObject()
        
        guard let dict = json as? [String: Any],
              let user = dict["user"] as? [String: Any],
              let tags = user["tags"] as? [Any] else {
            Issue.record("Expected nested structure")
            return
        }
        
        #expect(user["name"] as? String == "Jane")
        #expect(tags.count == 2)
        #expect(dict["count"] as? Int == 5)
    }
    
    // Note: Data value type test skipped as it depends on MCP SDK implementation
}

@Suite("Round-trip Conversion Tests")
struct RoundTripConversionTests {
    
    @Test("Round-trip string conversion")
    func testRoundTripString() {
        let original = "Test String"
        let value = Value.from(original)
        let json = value.toJSONObject()
        
        #expect(json as? String == original)
    }
    
    @Test("Round-trip number conversion")
    func testRoundTripNumber() {
        let original = 12345
        let value = Value.from(original)
        let json = value.toJSONObject()
        
        #expect(json as? Int == original)
    }
    
    @Test("Round-trip boolean conversion")
    func testRoundTripBoolean() {
        let original = true
        let value = Value.from(original)
        let json = value.toJSONObject()
        
        #expect(json as? Bool == original)
    }
    
    @Test("Round-trip array conversion")
    func testRoundTripArray() {
        let original: [Any] = [1, 2, 3, 4, 5]
        let value = Value.from(original)
        let json = value.toJSONObject()
        
        guard let array = json as? [Int] else {
            Issue.record("Expected integer array")
            return
        }
        
        #expect(array.count == 5)
        #expect(array[0] == 1)
        #expect(array[4] == 5)
    }
    
    @Test("Round-trip dictionary conversion")
    func testRoundTripDictionary() {
        let original: [String: Any] = [
            "id": "123",
            "value": 456,
            "flag": true
        ]
        
        let value = Value.from(original)
        let json = value.toJSONObject()
        
        guard let dict = json as? [String: Any] else {
            Issue.record("Expected dictionary")
            return
        }
        
        #expect(dict["id"] as? String == "123")
        #expect(dict["value"] as? Int == 456)
        #expect(dict["flag"] as? Bool == true)
    }
    
    @Test("Round-trip complex nested structure")
    func testRoundTripComplexStructure() {
        let original: [String: Any] = [
            "conference": [
                "name": "SwiftConf",
                "year": 2025,
                "tracks": ["iOS", "Backend", "Design"]
            ] as [String: Any],
            "sessions": [
                ["title": "Intro to Swift", "duration": 60] as [String: Any],
                ["title": "Advanced SwiftUI", "duration": 90] as [String: Any]
            ]
        ]
        
        let value = Value.from(original)
        let json = value.toJSONObject()
        
        guard let dict = json as? [String: Any],
              let conference = dict["conference"] as? [String: Any],
              let sessions = dict["sessions"] as? [[String: Any]] else {
            Issue.record("Expected nested structure")
            return
        }
        
        #expect(conference["name"] as? String == "SwiftConf")
        #expect(conference["year"] as? Int == 2025)
        #expect(sessions.count == 2)
        #expect(sessions[0]["title"] as? String == "Intro to Swift")
    }
}

@Suite("Edge Case Conversions")
struct EdgeCaseConversionTests {
    
    @Test("Convert very large number")
    func testConvertLargeNumber() {
        let largeNumber = Int.max
        let value = Value.from(largeNumber)
        
        if case .int(let num) = value {
            #expect(num == largeNumber)
        } else {
            Issue.record("Expected int value")
        }
    }
    
    @Test("Convert very small number")
    func testConvertSmallNumber() {
        let smallNumber = Int.min
        let value = Value.from(smallNumber)
        
        if case .int(let num) = value {
            #expect(num == smallNumber)
        } else {
            Issue.record("Expected int value")
        }
    }
    
    @Test("Convert zero")
    func testConvertZero() {
        let zero = 0
        let value = Value.from(zero)
        
        if case .int(let num) = value {
            #expect(num == 0)
        } else {
            Issue.record("Expected int value")
        }
    }
    
    @Test("Convert empty string")
    func testConvertEmptyString() {
        let empty = ""
        let value = Value.from(empty)
        
        if case .string(let str) = value {
            #expect(str.isEmpty)
        } else {
            Issue.record("Expected string value")
        }
    }
    
    @Test("Convert string with special characters")
    func testConvertSpecialCharacters() {
        let special = "Hello\nWorld\t\"Quote\""
        let value = Value.from(special)
        
        if case .string(let str) = value {
            #expect(str == special)
        } else {
            Issue.record("Expected string value")
        }
    }
    
    @Test("Convert string with Unicode")
    func testConvertUnicode() {
        let unicode = "Hello 👋 World 🌍"
        let value = Value.from(unicode)
        
        if case .string(let str) = value {
            #expect(str == unicode)
        } else {
            Issue.record("Expected string value")
        }
    }
    
    @Test("Convert deeply nested array")
    func testConvertDeeplyNestedArray() {
        let nested: [Any] = [
            [
                [
                    ["deep"]
                ]
            ]
        ]
        
        let value = Value.from(nested)
        
        if case .array(let arr1) = value,
           case .array(let arr2) = arr1[0],
           case .array(let arr3) = arr2[0],
           case .array(let arr4) = arr3[0],
           case .string(let str) = arr4[0] {
            #expect(str == "deep")
        } else {
            Issue.record("Expected deeply nested structure")
        }
    }
    
    @Test("Convert mixed type array")
    func testConvertMixedTypeArray() {
        let mixed: [Any] = [
            "string",
            123,
            45.67,
            true,
            ["nested": "dict"] as [String: Any]
        ]
        
        let value = Value.from(mixed)
        
        if case .array(let arr) = value {
            #expect(arr.count == 5)
        } else {
            Issue.record("Expected array value")
        }
    }
}

@Suite("Value Type Checking Tests")
struct ValueTypeCheckingTests {
    
    @Test("Check Value is string")
    func testValueIsString() {
        let value = Value.string("test")
        
        if case .string = value {
            // Success
        } else {
            Issue.record("Expected string type")
        }
    }
    
    @Test("Check Value is int")
    func testValueIsInt() {
        let value = Value.int(42)
        
        if case .int = value {
            // Success
        } else {
            Issue.record("Expected int type")
        }
    }
    
    @Test("Check Value is double")
    func testValueIsDouble() {
        let value = Value.double(3.14)
        
        if case .double = value {
            // Success
        } else {
            Issue.record("Expected double type")
        }
    }
    
    @Test("Check Value is bool")
    func testValueIsBool() {
        let value = Value.bool(true)
        
        if case .bool = value {
            // Success
        } else {
            Issue.record("Expected bool type")
        }
    }
    
    @Test("Check Value is array")
    func testValueIsArray() {
        let value = Value.array([])
        
        if case .array = value {
            // Success
        } else {
            Issue.record("Expected array type")
        }
    }
    
    @Test("Check Value is object")
    func testValueIsObject() {
        let value = Value.object([:])
        
        if case .object = value {
            // Success
        } else {
            Issue.record("Expected object type")
        }
    }
    
    @Test("Check Value is null")
    func testValueIsNull() {
        let value = Value.null
        
        if case .null = value {
            // Success
        } else {
            Issue.record("Expected null type")
        }
    }
}
