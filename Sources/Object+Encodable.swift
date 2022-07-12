// Object+Encodable.swift
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

import Foundation

// MARK: - Encodable Object extension

extension Object: Encodable {

    /// Encodes this object into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// objects format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .Nil:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case .Bool(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .Int(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .Double(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .String(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .Array(let value):
            var container = encoder.unkeyedContainer()
            try container.encode(value)
        case .JSON(let value):
            var container = encoder.container(keyedBy: DynamicCodingKey.self)
            try container.encode(value)
        }
    }

}

// MARK: - KeyedEncodingContainer extension

extension KeyedEncodingContainer where Key == DynamicCodingKey {

    /// Encodes the given value.
    ///
    /// - parameter value: The value to encode
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    mutating func encode(_ value: JSON) throws {

        for object in value {
            let key = DynamicCodingKey(object.key)

            switch object.value {
            case .Nil:
                try encodeNil(forKey: key)
            case .Bool(let value):
                try encode(value, forKey: key)
            case .Int(let value):
                try encode(value, forKey: key)
            case .Double(let value):
                try encode(value, forKey: key)
            case .String(let value):
                try encode(value, forKey: key)
            case .Array(let value):
                var container = nestedUnkeyedContainer(forKey: key)
                try container.encode(contentsOf: value)
            case .JSON(let value):
                var container = nestedContainer(keyedBy: DynamicCodingKey.self, forKey: key)
                try container.encode(value)
            }
        }
    }

}
