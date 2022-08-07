// ObjectDecodableSpec.swift
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

class ObjectDecodableTests: XCTestCase {

    let json = """
    {
        "id": 123456,
        "url": "https://test.com/object/1",
        "title": "Response",
        "null": null,
        "bool": true,
        "nested": {
            "id": 123456,
            "url": "https://test.com/object/2",
            "title": "Nested"
        },
        "empty": {},
        "array": [
            1,
            "2",
            3.4,
            {
                "five": 5
            },
            null
        ],
        "1": "one",
        "snake_case_key": "🐍"
    }
    """.data(using: .utf8)!

    struct Model: Codable {

        struct Nested: Codable {
            let id: Int
            let url: URL
            let title: String
        }

        struct Empty: Codable {
        }

        let id: Int
        let url: URL
        let title: String
        let null: Int?
        let bool: Bool
        let nested: Nested
        let empty: Empty
        let snakeCaseKey: String
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
        XCTAssertEqual(object.array.underestimatedCount, 5)
        XCTAssertEqual(object.array[0], 1)
        XCTAssertEqual(object.array[3].five, 5)
        XCTAssertEqual(object.1, "one")
        XCTAssertEqual(object.snakeCaseKey, "🐍")

        let model: Model = try ObjectDecoder().decode(from: object)
        XCTAssertEqual(model.id, 123456)
        XCTAssertEqual(object.title, "Response")
    }

    func testEncoding() throws {
        struct Model: Codable, Equatable {
            let integer: Int
            let double: Double
            let string: String
            let bool: Bool
            let array: [Int]
            let dictionary: [String: Int]
        }

        let model = Model(
            integer: 1,
            double: 1.1,
            string: "string",
            bool: true,
            array: [0, 1],
            dictionary: ["0": 0, "1": 1]
        )

        var object: Object = nil
        object.integer = 1
        object.double = 1.1
        object.string = "string"
        object.bool = true
        object.array = [0, 1]
        object.dictionary = ["0": 0, "1": 1]

        try XCTAssertJSONEqual(object, model)
    }

    func testTest() throws {
        let object = Object {
            $0.users = [
                Object { $0.username = "Tester 1" },
                Object { $0.username = "Tester 2" }
            ]
        }

        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        print(String(data: data, encoding: .utf8)!)
    }

    func testInteger() throws {
        try XCTAssertJSONEqual(Object.Int(-1), -1)
        try XCTAssertJSONEqual(Object.Int(0), 0)
        try XCTAssertJSONEqual(Object.Int(1), 1)
        try XCTAssertJSONEqual(Object.Int(1<<64), 1<<64)
    }

    func testDouble() throws {
        try XCTAssertJSONEqual(Object.Double(-0.1), -0.1)
        try XCTAssertJSONEqual(Object.Double(0.1), 0.1)
        try XCTAssertJSONEqual(Object.Double(.pi), Double.pi)
    }

    func testBoolean() throws {
        try XCTAssertJSONEqual(Object.Bool(false), false)
        try XCTAssertJSONEqual(Object.Bool(true), true)
    }

    func testString() throws {
        try XCTAssertJSONEqual(Object.String(""), "")
        try XCTAssertJSONEqual(Object.String("test"), "test")
    }

    func testArray() throws {
        try XCTAssertJSONEqual(Object.Array([] as [Object]), [] as [Int])
        try XCTAssertJSONEqual(Object.Array([0]), [0])
        try XCTAssertJSONEqual(Object.Array([Object](repeating: 1.1, count: 100)), [Double](repeating: 1.1, count: 100))
    }

    func testJSON() throws {
        struct Model: Codable, Equatable {
            struct Nested: Codable, Equatable {
                let integer: Int
            }

            let integer: Int
            let double: Double
            let string: String
            let bool: Bool
            let array: [Int]
            let dictionary: [String: Int]
            let nested: Nested
        }

        let model = Model(
            integer: 1,
            double: 1.1,
            string: "string",
            bool: true,
            array: [0, 1],
            dictionary: ["0": 0, "1": 1],
            nested: Model.Nested(integer: 2)
        )

        let object: Object = Object {
            $0.integer = 1
            $0.double = 1.1
            $0.string = "string"
            $0.bool = true
            $0.array = [0, 1]
            $0.dictionary = ["0": 0, "1": 1]
            $0.nested = Object {
                $0.integer = 2
            }
        }

        try XCTAssertJSONEqual(object, model)
    }
}

func XCTAssertJSONEqual<LHS, RHS>(_ lhs: LHS, _ rhs: RHS) throws where LHS: Codable, LHS: Equatable, RHS: Codable, RHS: Equatable {
    let encoder = JSONEncoder()

    let encoded = try (
        lhs: encoder.encode(lhs),
        rhs: encoder.encode(rhs)
    )

    print(String(data: encoded.lhs, encoding: .utf8)!)
    print(String(data: encoded.rhs, encoding: .utf8)!)

    let decoder = JSONDecoder()
    let decoded = try (
        lhs: decoder.decode(RHS.self, from: encoded.lhs),
        rhs: decoder.decode(LHS.self, from: encoded.rhs)

    )

    XCTAssertEqual(lhs, decoded.rhs)
    XCTAssertEqual(rhs, decoded.lhs)
}
