// Object+Decodable.swift
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

// MARK: - Decodable Object extension

extension Object: Decodable {

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        self = try decoder.decode(Object.self)
    }
}

// MARK: - Decoder extension

extension Decoder {

    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    /// - throws: `DecodingError.typeMismatch` if an encountered encoded value
    ///   is invalid.
    func decode(_ type: Object.Type) throws -> Object {
        if let container = try? container(keyedBy: DynamicCodingKey.self), let value = try? container.decode(type) {
            return value
        }

        if var container = try? unkeyedContainer(), let value = try? container.decode(type) {
            return value
        }

        if let container = try? singleValueContainer(), let value = try? container.decode(type) {
            return value
        }

        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid type in JSON")
        throw DecodingError.dataCorrupted(context)
    }
}

// MARK: - KeyedDecodingContainer extension

extension KeyedDecodingContainer {

    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DecodingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    /// - throws: `DecodingError.typeMismatch` if an encountered encoded value
    ///   is invalid.
    func decode(_ type: Object.Type) throws -> Object {
        var json = JSON()

        for key in allKeys {
            json[key.stringValue] = try decode(Object.self, forKey: key)
        }

        return .JSON(json)
    }
}

// MARK: - UnkeyedDecodingContainer extension

extension UnkeyedDecodingContainer {

    /// Decodes next value.
    ///
    /// - parameter type: The type of value to decode.
    /// - returns: An object.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value
    ///   is null, or of there are no more values to decode.
    /// - throws: `DecodingError.typeMismatch` if an encountered encoded value
    ///   is invalid.
    mutating func decode(_ type: Object.Type) throws -> Object {
        var array: [Object] = []

        while isAtEnd == false {
            let value = try decodeNext()
            array.append(value)
        }

        return .Array(array)
    }

    /// Decodes next object value.
    ///
    /// - returns: An object.
    /// - throws: `DecodingError.typeMismatch` if an encountered encoded value
    ///   is invalid.
    mutating func decodeNext() throws -> Object {

        if try decodeNil() {
            return .Nil
        }

        if let value = try? decode(Bool.self) {
            return .Bool(value)
        }

        if let value = try? decode(Int64.self) {
            return .Int(value)
        }

        if let value = try? decode(Double.self) {
            return .Double(value)
        }

        if let value = try? decode(String.self) {
            return .String(value)
        }

        if let value = try? decode(JSON.self) {
            return .JSON(value)
        }

        if var container = try? nestedUnkeyedContainer(), let value = try? container.decode([Object].self) {
            return .Array(value)
        }

        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid type in JSON")
        throw DecodingError.typeMismatch(Object.self, context)
    }
}

// MARK: - SingleValueDecodingContainer extension

extension SingleValueDecodingContainer {

    /// Decodes a single value of the given type.
    ///
    /// - parameter type: The type to decode as.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.typeMismatch` if an encountered encoded value
    ///   is invalid.
    func decode(_ type: Object.Type) throws -> Object {

        if let value = try? decode(Bool.self) {
            return .Bool(value)
        }

        if let value = try? decode(Int64.self) {
            return .Int(value)
        }

        if let value = try? decode(Double.self) {
            return .Double(value)
        }

        if let value = try? decode(String.self) {
            return .String(value)
        }

        if decodeNil() {
            return .Nil
        }

        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid type in JSON")
        throw DecodingError.typeMismatch(Object.self, context)
    }
}
