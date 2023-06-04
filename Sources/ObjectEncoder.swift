// ObjectEncoder.swift
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

/// An object that encodes instances of a Encodable type as Dynamics Object.
///
/// The example below shows how to encode an instance of a simple GroceryProduct type from a JSON object.
/// The type adopts Codable so that it's encodable as JSON using a JSONEncoder instance.
///
///     struct GroceryProduct: Codable {
///         var name: String
///         var points: Int
///         var description: String?
///     }
///
///     let pear = GroceryProduct(name: "Pear", points: 250, description: "A ripe pear.")
///
///     let encoder = ObjectEncoder()
///
///     let object = try encoder.encode(pear)
///     print(String(object, encoding: .utf8)!)
///
///     /* Prints:
///     {
///         "name" : "Pear",
///         "points" : 250,
///         "description" : "A ripe pear."
///     }
///     */
open class ObjectEncoder {

  /// Initializes `self` with default strategies.
  public init() {

  }

  /// Encodes the given top-level value and returns its Object representation.
  ///
  /// - parameter value: The value to encode.
  /// - returns: A new `Data` value containing the encoded JSON data.
  /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
  /// - throws: An error if any value throws an error during encoding.
  open func encode<T>(_ value: T) throws -> Object where T: Encodable {
    let container = ObjectMemberEncoder.SingleValueContainer()
    try container.encode(value)
    return container.object
  }
}

// swiftlint:enable closing_brace_whitespace

// MARK: - Internal Encoder

/// A container that can support the storage and direct decoding of an `Object`..
internal protocol ObjectEncodingContainer {

  /// The contained `Object`.
  var object: Object { get }
}

internal class ObjectMemberEncoder: Encoder {

  let codingPath: [CodingKey]

  let userInfo: [CodingUserInfoKey: Any] = [:]

  private var container: ObjectEncodingContainer?

  init(path: [CodingKey] = []) {
    codingPath = path
  }

  /// The contained `Object`.
  var object: Object { container?.object ?? .Nil }

  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    let container = KeyedContainer<Key>(path: codingPath)
    self.container = container
    return KeyedEncodingContainer(container)
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    let container = UnkeyedContainer(path: codingPath)
    self.container = container
    return container
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    let container = SingleValueContainer(path: codingPath)
    self.container = container
    return container
  }

  class KeyedContainer<Key>: KeyedEncodingContainerProtocol, ObjectEncodingContainer
  where Key: CodingKey {

    var codingPath: [CodingKey]

    private var containers: [String: ObjectEncodingContainer] = [:]

    init(path: [CodingKey] = []) {
      self.codingPath = path
    }

    /// The contained `Object`.
    var object: Object {
      let json = containers.mapValues { $0.object }
      return .JSON(json)
    }

    func encodeNil(forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encodeNil()
    }

    func encode(_ value: Bool, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: String, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Double, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Float, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Int, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Int8, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Int16, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Int32, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: Int64, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: UInt, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: UInt8, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: UInt16, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: UInt32, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode(_ value: UInt64, forKey key: Key) throws {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
      try nestedSingleValueContainer(forKey: key).encode(value)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
      -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
      let container = KeyedContainer<NestedKey>(path: codingPath + [key])
      containers[key.stringValue] = container
      return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
      let container = UnkeyedContainer(path: codingPath + [key])
      containers[key.stringValue] = container
      return container
    }

    func nestedSingleValueContainer(forKey key: Key) -> SingleValueContainer {
      let container = SingleValueContainer(path: codingPath + [key])
      containers[key.stringValue] = container
      return container
    }

    func superEncoder() -> Encoder {
      ObjectMemberEncoder(path: codingPath)
    }

    func superEncoder(forKey key: Key) -> Encoder {
      ObjectMemberEncoder(path: codingPath + [key])
    }
  }

  class UnkeyedContainer: UnkeyedEncodingContainer, ObjectEncodingContainer {

    let codingPath: [CodingKey]

    var count: Int { containers.count }

    private var containers: [ObjectEncodingContainer] = []

    init(path: [CodingKey] = []) {
      self.codingPath = path
    }

    var object: Object {
      let array = containers.map { $0.object }
      return .Array(array)
    }

    func encodeNil() throws {
      try nestedSingleValueContainer().encodeNil()
    }

    func encode(_ value: Bool) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: String) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Double) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Float) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Int) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Int8) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Int16) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Int32) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: Int64) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: UInt) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: UInt8) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: UInt16) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: UInt32) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode(_ value: UInt64) throws {
      try nestedSingleValueContainer().encode(value)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
      try nestedSingleValueContainer().encode(value)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<
      NestedKey
    > where NestedKey: CodingKey {
      let container = KeyedContainer<NestedKey>(path: codingPath)
      containers.append(container)
      return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
      let container = UnkeyedContainer(path: codingPath)
      containers.append(container)
      return container
    }

    func nestedSingleValueContainer() -> SingleValueContainer {
      let container = SingleValueContainer(path: codingPath)
      containers.append(container)
      return container
    }

    func superEncoder() -> Encoder {
      ObjectMemberEncoder(path: codingPath)
    }
  }

  class SingleValueContainer: SingleValueEncodingContainer, ObjectEncodingContainer {

    let codingPath: [CodingKey]

    var object: Object = .Nil

    init(path: [CodingKey] = []) {
      self.codingPath = path
    }

    func encodeNil() throws {
      object = .Nil
    }

    func encode(_ value: Bool) throws {
      try value.encode(to: self)
    }

    func encode(_ value: String) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Double) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Float) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Int) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Int8) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Int16) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Int32) throws {
      try value.encode(to: self)
    }

    func encode(_ value: Int64) throws {
      try value.encode(to: self)
    }

    func encode(_ value: UInt) throws {
      try value.encode(to: self)
    }

    func encode(_ value: UInt8) throws {
      try value.encode(to: self)
    }

    func encode(_ value: UInt16) throws {
      try value.encode(to: self)
    }

    func encode(_ value: UInt32) throws {
      try value.encode(to: self)
    }

    func encode(_ value: UInt64) throws {
      try value.encode(to: self)
    }

    func encode<T>(_ value: T) throws where T: Encodable {

      // `ObjectEncodable` is prioritize over `Decodable`.
      if let value = value as? ObjectEncodable {
        try value.encode(to: self)

      } else {
        let encoder = ObjectMemberEncoder(path: codingPath)
        try value.encode(to: encoder)
        object = encoder.object
      }
    }
  }
}

// MARK: Decoder Error extension

extension EncodingError {

  /// An indication that an encoder or its containers could not encode the
  /// given value.
  ///
  /// As associated values, this case contains the attempted value and context
  /// for debugging.
  ///
  /// - Parameters:
  ///   - Any: The value to convert to `Object`
  ///   - container: The container in which the corrupted data was
  ///   accessed.
  static func invalidValue(_ any: Any, in container: SingleValueEncodingContainer) -> EncodingError
  {
    let description = "Invalid conversion of '\(any)' to DynamicObject.Object"
    let context = EncodingError.Context(
      codingPath: container.codingPath, debugDescription: description)
    return .invalidValue(any, context)
  }
}
