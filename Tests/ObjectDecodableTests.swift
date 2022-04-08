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

    struct Model: Codable {

        struct Nested: Codable {
            let id: Int
            let url: URL
            let title: String
            let date: Date
        }

        struct Empty: Codable {
        }

        let id: Int
        let url: URL
        let title: String
        let date: Date
        let null: Int?
        let bool: Bool
        let nested: Nested
        let empty: Empty
        let snakeCaseKey: String

    }

    func testDecoding() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let object = try decoder.decode(Object.self, from: self.json)
        
        let model: Model = try ObjectDecoder().decode(from: object)
        XCTAssertEqual(model.id, 123456)
        XCTAssertEqual(model.title, "Response")
    }

    func testEncoding() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let model = try decoder.decode(Model.self, from: self.json)
        let encoder = ObjectEncoder()
        let object = try encoder.encode(model)
        XCTAssertEqual(object.id, 123456)
        XCTAssertEqual(object.title, "Response")
    }

}
