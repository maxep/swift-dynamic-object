// ObjectSpec.swift
//
// Copyright (c) 2022 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest

@testable import DynamicObject

class ObjectTests: XCTestCase {

    let json = """
    {
        "id": 123456,
        "url": "https://test.com/object/1",
        "title": "Response",
        "date": "2018-09-12T19:56:56+00:00",
        "null": null,
        "bool": true,
        "nested": {
            "id": 123456,
            "url": "https://test.com/object/2",
            "title": "Nested",
            "date": "2018-09-12T19:56:56+00:00"
        },
        "empty": {},
        "array": [
            1,
            "2",
            3.4,
            {
                "five": 5
            },
            "2019-01-01T00:00:00+00:00",
            null
        ],
        "1": "one",
        "snake_case_key": "🐍"
    }
    """.data(using: .utf8)!

    struct Model: Decodable {
        let id: Int
        let url: URL
        let title: String
        let date: Date
        let bool: Bool
    }

    func testNilLiteralExpression() {
        let value: Object = nil
        XCTAssertEqual(value, .Nil)
    }

    func testBooleanLiteralExpression() {
        let value: Object = true
        XCTAssertEqual(value, .Bool(true))
    }

    func testIntegerLiteralExpression() {
        let value: Object = 123456
        XCTAssertEqual(value, .Int(123456))
    }

    func testDoubleLiteralExpression() {
        let value: Object = 123.456
        XCTAssertEqual(value, .Double(123.456))
    }

    func testStringLiteralExpression() {
        let value: Object = "heliotrope"
        XCTAssertEqual(value, .String("heliotrope"))
    }

    func testArrayLiteralExpression() {
        let value: Object = ["heliotrope", 296]
        XCTAssertEqual(value.underestimatedCount, 2)
        XCTAssertEqual(value[0], .String("heliotrope"))
        XCTAssertEqual(value[1], .Int(296))
    }

    func testDictionaryLiteralExpression() {
        let value: Object = ["first": 296, "last": 16]
        XCTAssertEqual(value.underestimatedCount, 2)
        XCTAssertEqual(value["first"], .Int(296))
        XCTAssertEqual(value.first, .Int(296))
        XCTAssertEqual(value.last, .Int(16))
    }

    func testSetBooleanMember() {
        var bool: Bool = false

        var object: Object = [:]

        object.bool = true
        bool = object.bool!
        XCTAssertTrue(bool)
        object.bool = false
        bool = object.bool!
        XCTAssertFalse(bool)
        object.bool = "true"
        bool = object.bool!
        XCTAssertTrue(bool)
        object.bool = -1
        bool = object.bool!
        XCTAssertTrue(bool)
        object.bool = 0.00
        bool = object.bool!
        XCTAssertFalse(bool)
    }

    func testSetSignedIntegerMember() {
        var int4: Int? = 4
        var int8: Int8? = 8
        var int16: Int16? = 16
        var int32: Int32? = 32
        var int64: Int64? = 64

        var object: Object = [:]

        object.int4 = int4
        XCTAssertEqual(object.int4, 4)
        object.int4 = -4
        int4 = object.int4
        XCTAssertEqual(int4, -4)

        object.int8 = int8
        XCTAssertEqual(object.int8, 8)
        object.int8 = -8
        int8 = object.int8
        XCTAssertEqual(int8, -8)

        object.int16 = int16
        XCTAssertEqual(object.int16, 16)
        object.int16 = -16
        int16 = object.int16
        XCTAssertEqual(int16, -16)

        object.int32 = int32
        XCTAssertEqual(object.int32, 32)
        object.int32 = -32
        int32 = object.int32
        XCTAssertEqual(int32, -32)

        object.int64 = int64
        XCTAssertEqual(object.int64, 64)
        object.int64 = -64
        int64 = object.int64
        XCTAssertEqual(int64, -64)

        object.string = "128"
        XCTAssertEqual(object.string, 128)
        object.string = "-128"
        let int: Int? = object.string
        XCTAssertEqual(int, -128)
    }

    func testSetUnSignedIntegerMember() {
        var uint4: UInt? = 4
        var uint8: UInt8? = 8
        var uint16: UInt16? = 16
        var uint32: UInt32? = 32
        var uint64: UInt64? = 64

        var object: Object = [:]

        object.uint4 = uint4
        XCTAssertEqual(object.uint4, 4)
        object.uint4 = 0
        uint4 = object.uint4
        XCTAssertEqual(uint4, 0)

        object.uint8 = uint8
        XCTAssertEqual(object.uint8, 8)
        object.uint8 = 0
        uint8 = object.uint8
        XCTAssertEqual(uint8, 0)

        object.uint16 = uint16
        XCTAssertEqual(object.uint16, 16)
        object.uint16 = 0
        uint16 = object.uint16
        XCTAssertEqual(uint16, 0)

        object.uint32 = uint32
        XCTAssertEqual(object.uint32, 32)
        object.uint32 = 0
        uint32 = object.uint32
        XCTAssertEqual(uint32, 0)

        object.uint64 = uint64
        XCTAssertEqual(object.uint64, 64)
        object.uint64 = 0
        uint64 = object.uint64
        XCTAssertEqual(uint64, 0)

        object.string = "128"
        XCTAssertEqual(object.string, 128)
        object.string = "0"
        let int: Int? = object.string
        XCTAssertEqual(int, 0)
    }

    func testSetStringMember() {
        var string: String? = "Adams"

        var object: Object = [:]

        object.string = string
        XCTAssertEqual(object.string, "Adams")
        object.string = "Bryant"
        string = object.string
        XCTAssertEqual(string, "Bryant")

        object.string = true
        string = object.string
        XCTAssertEqual(object.string, "true")

        object.string = 0
        string = object.string
        XCTAssertEqual(string, "0")

        object.string = 3.14
        string = object.string
        XCTAssertEqual(string, "3.14")

        object.string = Date(timeIntervalSinceReferenceDate: 0)
        string = object.string
        XCTAssertEqual(string, "2001-01-01T00:00:00Z")
    }

    func testSetDoubleMember() {
        var double: Double? = 123.456

        var object: Object = [:]

        object.double = double
        XCTAssertEqual(object.double, 123.456)
        object.double = 654.321
        double = object.double
        XCTAssertEqual(double, 654.321)

        object.string = "123.456"
        double = object.string
        XCTAssertEqual(double, 123.456)
    }

    func testSetFloatMember() {
        var float: Float? = 123.456

        var object: Object = [:]

        object.float = float
        XCTAssertEqual(object.float, float)
        object.float = 654.321
        float = object.float
        XCTAssertEqual(float, 654.321)

        object.string = "123.456"
        float = object.string
        XCTAssertEqual(float, 123.456)
    }

    func testSetStringEnumMember() {
        enum Enum: String, Codable {
            case case1
            case case2
        }

        var value: Enum? = Enum.case1
        var object: Object = [:]

        object.case = value
        XCTAssertEqual(object.case, Enum.case1)
        object.case = Enum.case2
        value = object.case
        XCTAssertEqual(value, Enum.case2)
    }

    func testSetIntEnumMember() {
        enum Enum: Int, Codable {
            case case1
            case case2
        }

        var value: Enum? = Enum.case1
        var object: Object = [:]

        object.case = value
        XCTAssertEqual(object.case, Enum.case1)
        object.case = Enum.case2
        value = object.case
        XCTAssertEqual(value, Enum.case2)
    }

    func testSetNestedObjectMember() {
        var object: Object = [:]
        object.nested.nested.nested = "value"
        XCTAssertNotNil(object.nested)
        XCTAssertNotNil(object.nested.nested)
        XCTAssertEqual(object.nested.nested.nested, "value")
    }

    func testNotIndexedObjectFailure() {
        var object: Object = "value"
        object[0] = 0
        XCTAssertEqual(object[0], .Nil)
    }

    func testObjectGetArray() {
        let object: Object = ["items": ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]]
        let items: [String]? = object.items
        XCTAssertEqual(items?.count, 5)
    }

    func testObjectGetDictionary() {
        let object: Object = ["item": ["nested": ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]]]
        let items: JSON? = object.item
        XCTAssertEqual(items?["nested"]?.count, 5)
    }

    func testMutateArray() {
        var streets: Object = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
        streets[0] = "Butler"
        XCTAssertEqual(streets[0], "Butler")
    }

    func testMutateDictionary() {
        var hues: Object = ["heliotrope": 296, "coral": 16, "aquamarine": 156]

        XCTAssertEqual(hues["coral"], 16)
        XCTAssertNil(hues["cerise"])

        hues["coral"] = 18
        XCTAssertEqual(hues["coral"], 18)

        hues["cerise"] = 330
        XCTAssertEqual(hues["cerise"], 330)
    }

    func testMutateObject() {
        var hues: Object = ["heliotrope": 296, "coral": 16, "aquamarine": 156]

        XCTAssertEqual(hues.coral, 16)
        XCTAssertEqual(hues.cerise, .Nil)

        hues.coral = 18
        XCTAssertEqual(hues.coral, 18)

        hues.cerise = 330
        XCTAssertEqual(hues.cerise, 330)
    }

    func testLoopArrayObject() {
        let streets: Object = ["Adams", "Adams", "Adams", "Adams", "Adams"]
        for street in streets {
            XCTAssertEqual(street.object, "Adams")
        }
    }

    func testLoopDictionaryObject() {
        let streets: Object =  ["heliotrope": 1, "coral": 1, "aquamarine": 1]
        for street in streets {
            XCTAssertEqual(street.object, 1)
        }
    }

    func testNoLoop() {
        let object: Object = 1
        for _ in object {
            XCTFail()
        }
    }

    func test0Count() {
        let object: Object = 1
        XCTAssertEqual(object.underestimatedCount, 0)
    }

    func testDecoding() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let object = try decoder.decode(Object.self, from: self.json)

        XCTAssertEqual(object.bool, true)
        XCTAssertEqual(object.id, 123456)
        XCTAssertEqual(object.title, "Response")
        XCTAssertEqual(object.url, "https://test.com/object/1")
        XCTAssertEqual(try object.url.unwrap(), URL(string: "https://test.com/object/1"))
        XCTAssertNotNil(object.nested)
        XCTAssertEqual(object.nested.id, 123456)
        XCTAssertNotNil(object.null)
        XCTAssertNotNil(object.array)
        XCTAssertEqual(object.array.underestimatedCount, 6)
        XCTAssertEqual(object.array[0], 1)
        XCTAssertEqual(object.array[3].five, 5)
        XCTAssertNotNil(object.date)
        XCTAssertEqual(object.1, "one")
        XCTAssertEqual(object.snakeCaseKey, "🐍")

        let model: Model = try ObjectDecoder().decode(from: object)
        XCTAssertEqual(model.id, 123456)
        XCTAssertEqual(object.title, "Response")
    }

    func testEncoding() throws {
        let encoder = JSONEncoder()

        var object: Object = nil
        object.value = true
        _ = try encoder.encode(object)

        object = nil
        object.value = 123456
        _ = try encoder.encode(object)

        object = nil
        object.value = "value"
        _ = try encoder.encode(object)

        object = nil
        object.value = URL(string: "https://test.com/object/1")
        _ = try encoder.encode(object)

        object = nil
        object.value = nil
        _ = try encoder.encode(object)

        object = nil
        object.value.value = 123456
        _ = try encoder.encode(object)

        object = ["Adams", "Adams", "Adams", "Adams", "Adams"]
        _ = try encoder.encode(object)

        object = ["heliotrope": 1, "coral": 1, "aquamarine": 1]
        _ = try encoder.encode(object)
    }

    func testEqualOperator() {
        let lhs: Object = 1
        let rhs: Object = 1
        XCTAssertTrue(lhs == rhs)
    }

    func testMapPrimaryTypes() throws {
        var object: Object = 0

        object = try object.map { _ in "" }
        XCTAssertEqual(object, "")

        object = try object.map { _ in true }
        XCTAssertEqual(object, true)

        object = try object.map { _ in 3.14 }
        XCTAssertEqual(object, 3.14)

        object = try object.map { _ in 0 }
        XCTAssertEqual(object, 0)

        object = try object.map { _ in Object.Nil }
        XCTAssertEqual(object, .Nil)
    }

    func testMapArray() throws {
        var object: Object = ["Adams", "Adams", "Adams", "Adams", "Adams"]

        object = try object.map { _ in 0 }
        XCTAssertEqual(object.count, 5)
        XCTAssertEqual(object.first, 0)
        XCTAssertEqual(object.last, 0)

        object = try object.map { _ in 0 }
        XCTAssertEqual(object.count, 5)
        XCTAssertEqual(object.first, 0)
        XCTAssertEqual(object.last, 0)

        object = try object.compactMap { _ in nil as Int? }
        XCTAssertEqual(object.count, 0)
    }

    func testMapObject() throws {
        var object = try JSONDecoder().decode(Object.self, from: self.json)

        object = try object.map { _ in 0 }
        XCTAssertEqual(object.id, 0)
        XCTAssertNotNil(object.nested)
        XCTAssertEqual(object.nested.id, 0)

        object = try object.compactMap { _ in 0 }
        XCTAssertEqual(object.id, 0)
        XCTAssertNotNil(object.nested)
        XCTAssertEqual(object.nested.id, 0)

        object = try object.compactMap { _ in nil as String? }
        XCTAssertEqual(object, .Nil)
    }

    func testObjectDescription() {
        var object: Object = nil
        XCTAssertEqual(String(describing: object), "(null)")
        XCTAssertEqual(String(reflecting: object), "(null)")
        object = true
        XCTAssertEqual(String(describing: object), "true")
        XCTAssertEqual(String(reflecting: object), "true")
        object = 0
        XCTAssertEqual(String(describing: object), "0")
        XCTAssertEqual(String(reflecting: object), "0")
        object = "string"
        XCTAssertEqual(String(describing: object), "string")
        XCTAssertEqual(String(reflecting: object), "\"string\"")
        object = 6.66
        XCTAssertEqual(String(describing: object), "6.66")
        XCTAssertEqual(String(reflecting: object),"6.66")
        object = ["array"]
        XCTAssertEqual(String(describing: object), "[\"array\"]")
        XCTAssertEqual(String(reflecting: object), "[\"array\"]")
        object = ["key": "value"]
        XCTAssertEqual(String(describing: object), "{\"key\":\"value\"}")
        XCTAssertEqual(String(reflecting: object), "{\n  \"key\" : \"value\"\n}")
    }
}
