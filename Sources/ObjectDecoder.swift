// ObjectDecoder.swift
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

// swiftlint:disable closing_brace_whitespace

/// An object that decodes instances of a data type from JSON objects.
///
/// The example below shows how to decode an instance of a simple GroceryProduct type from a JSON object. The type adopts Codable so that it's decodable using a JSONDecoder instance.
///
///     struct GroceryProduct: Codable {
///         var name: String
///         var points: Int
///         var description: String?
///     }
///
///     let json: Object = [
///         "name": "Durian",
///         "points": 600,
///         "description": "A fruit with a distinctive scent."
///     ]
///
///     let decoder = ObjectDecoder()
///     let product = try decoder.decode(GroceryProduct.self, from: json)
///
///     print(product.name) // Prints "Durian"
///
open class ObjectDecoder {

  /// Initializes `self`.
  public init() {

  }

  /// Decodes a top-level value of the given type from the given Object representation.
  ///
  /// - parameter type: The type of the value to decode.
  /// - parameter object: The object to decode from.
  /// - returns: A value of the requested type.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
  /// - throws: An error if any value throws an error during decoding.
  open func decode<T>(_ type: T.Type, from object: Object) throws -> T where T: Decodable {
    let container = ObjectMemberDecoder.SingleValueContainer(object)
    return try container.decode(T.self)
  }

  /// Decodes a top-level value of the given type from the given Object representation.
  ///
  /// - parameter object: The object to decode from.
  /// - returns: A value of the requested type.
  /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
  /// - throws: An error if any value throws an error during decoding.
  open func decode<T>(from object: Object) throws -> T where T: Decodable {
    try decode(T.self, from: object)
  }
}

// swiftlint:enable closing_brace_whitespace

// MARK: - Internal Decoder

internal class ObjectMemberDecoder: Decoder {

  let object: Object

  let codingPath: [CodingKey]

  let userInfo: [CodingUserInfoKey: Any] = [:]

  init(_ object: Object, path: [CodingKey] = []) {
    self.object = object
    codingPath = path
  }

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
  where Key: CodingKey {
    let container = KeyedContainer<Key>(object, path: codingPath)
    return KeyedDecodingContainer(container)
  }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    UnkeyedContainer(object, path: codingPath)
  }

  func singleValueContainer() throws -> SingleValueDecodingContainer {
    SingleValueContainer(object, path: codingPath)
  }

  struct KeyedContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {

    let codingPath: [CodingKey]

    let object: Object

    init(_ object: Object, path: [CodingKey] = []) {
      self.object = object
      self.codingPath = path
    }

    var allKeys: [Key] {
      guard case let .JSON(json) = object else { return [] }
      return json.keys.compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: Key) -> Bool {
      object[key.stringValue] != nil
    }

    func object(forKey key: Key) throws -> Object {

      guard let object = object[key.stringValue] else {
        throw DecodingError.keyNotFound(
          key,
          DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: "No value associated with key \(key.stringValue)."))
      }

      return object
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      try nestedSingleValueContainer(forKey: key).decodeNil()
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
      try nestedSingleValueContainer(forKey: key).decode(type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let container = try KeyedContainer<NestedKey>(object(forKey: key), path: codingPath + [key])
      return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      try UnkeyedContainer(object(forKey: key), path: codingPath + [key])
    }

    func nestedSingleValueContainer(forKey key: Key) throws -> SingleValueDecodingContainer {
      try SingleValueContainer(object(forKey: key), path: codingPath + [key])
    }

    func superDecoder() throws -> Decoder {
      ObjectMemberDecoder(object, path: codingPath)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
      try ObjectMemberDecoder(object(forKey: key), path: codingPath + [key])
    }
  }

  struct UnkeyedContainer: UnkeyedDecodingContainer {

    let codingPath: [CodingKey]

    let object: Object

    init(_ object: Object, path: [CodingKey] = []) {
      self.object = object
      self.codingPath = path
    }

    var count: Int? { object.count }

    var isAtEnd: Bool { currentIndex >= object.count }

    private(set) var currentIndex: Int = 0

    mutating func decodeNil() throws -> Bool {
      try nestedSingleValueContainer().decodeNil()
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: String.Type) throws -> String {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      try nestedSingleValueContainer().decode(type)
    }

    mutating func next() throws -> Object {
      defer { currentIndex += 1 }

      guard !isAtEnd else {
        throw DecodingError.valueNotFound(
          Object.self,
          DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Unkeyed container is at end."))
      }

      return object[currentIndex]
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let container = try KeyedContainer<NestedKey>(next(), path: codingPath)
      return KeyedDecodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      try UnkeyedContainer(next(), path: codingPath)
    }

    mutating func nestedSingleValueContainer() throws -> SingleValueDecodingContainer {
      try SingleValueContainer(next(), path: codingPath)
    }

    mutating func superDecoder() throws -> Decoder {
      ObjectMemberDecoder(object, path: codingPath)
    }
  }

  struct SingleValueContainer: SingleValueDecodingContainer {

    let codingPath: [CodingKey]

    let object: Object

    init(_ object: Object, path: [CodingKey] = []) {
      self.object = object
      self.codingPath = path
    }

    func decodeNil() -> Bool {
      object == .Nil
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      try Bool(from: self)
    }

    func decode(_ type: String.Type) throws -> String {
      try String(from: self)
    }

    func decode(_ type: Double.Type) throws -> Double {
      try Double(from: self)
    }

    func decode(_ type: Float.Type) throws -> Float {
      try Float(from: self)
    }

    func decode(_ type: Int.Type) throws -> Int {
      try Int(from: self)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      try Int8(from: self)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      try Int16(from: self)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      try Int32(from: self)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      try Int64(from: self)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      try UInt(from: self)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      try UInt8(from: self)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      try UInt16(from: self)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      try UInt32(from: self)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      try UInt64(from: self)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {

      // `ObjectDecodable` is prioritize over `Decodable`.
      if let type = type as? ObjectDecodable.Type {
        return try type.init(from: self) as! T  // swiftlint:disable:this force_cast
      }

      let decoder = ObjectMemberDecoder(object, path: codingPath)
      return try T(from: decoder)
    }
  }
}

// MARK: Decoder Error extension

extension DecodingError {

  /// Returns a new `.dataCorrupted` error using a constructed coding path.
  ///
  /// The coding path for the returned error is the given container's coding
  /// path.
  ///
  /// - Parameters:
  ///   - type: The type to convert to.
  ///   - container: The container in which the corrupted data was
  ///   accessed.
  ///
  /// - Returns: A new `.dataCorrupted` error with the given information.
  static func dataConversionError<T>(
    to type: T.Type, in container: ObjectMemberDecoder.SingleValueContainer
  ) -> DecodingError {
    let description = "Invalid conversion of '\(container.object)' to \(type)"
    let context = DecodingError.Context(
      codingPath: container.codingPath, debugDescription: description)
    return dataCorrupted(context)
  }
}
