// Object+Accessors.swift
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

extension Object {

  /// Returns converted value, or throws error.
  ///
  ///     let object: Object = true
  ///     let bool: Bool = try value.unwrap()
  ///     try print(bool)
  ///     // Prints "true"
  ///
  ///     let object: Object = ""
  ///     let bool: Bool = try? value.unwrap()
  ///     // Throws error
  public func unwrap<T>() throws -> T where T: Decodable {
    let decoder = ObjectDecoder()
    return try decoder.decode(from: self)
  }

  /// Returns an Object containing the results of mapping the given closure
  /// over the object's elements.
  ///
  /// In this example, `map` is used first to convert the names in the array
  /// to lowercase strings and then to count their characters.
  ///
  ///     let object: Object = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let lowercaseNames: [String] = cast.map { $0.lowercased() }
  ///     // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
  ///     let letterCounts: [Int] = cast.map { $0.count }
  ///     // 'letterCounts' == [6, 6, 3, 4]
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of this sequence as its parameter and returns a transformed
  ///   value of the same or of a different type.
  /// - Returns: An object containing the transformed elements.
  public func map<T>(_ transform: (Object) throws -> T) throws -> Object where T: Encodable {
    let encoder = ObjectEncoder()

    switch self {
    case .Nil, .Bool, .Int, .Double, .String:
      let encodable = try transform(self)
      return try encoder.encode(encodable)

    case .Array(let value):
      let array: [Object] = try value.map { try $0.map(transform) }
      return .Array(array)

    case .JSON(let value):
      let json: JSON = try value.mapValues { try $0.map(transform) }
      return .JSON(json)
    }
  }

  /// Returns an Object containing the non-`nil` results of calling the given
  /// transformation with each element of this object.
  ///
  /// Use this method to receive an object of nonoptional values when your
  /// transformation produces an optional value.
  ///
  /// In this example, note the difference in the result of using `map` and
  /// `compactMap` with a transformation that returns an optional `Int` value.
  ///
  ///     let possibleNumbers: Object = ["1", "2", "three", "|||4|||", "5"]
  ///
  ///     let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
  ///     // [1, 2, null, null, 5]
  ///
  ///     let compactMapped: [Int] = possibleNumbers.compactMap { str in
  ///         guard let value = Int(str) else { return nil }
  ///         return value
  ///     } // swiftlint:disable closing_brace_whitespace
  ///     // [1, 2, 5]
  ///
  /// - Parameter transform: A closure that accepts an element of this
  ///   object as its argument and returns an optional value.
  /// - Returns: An Object of the non-`nil` results of calling `transform`
  ///   with each element of the object.
  ///
  /// - Complexity: O(*m* + *n*), where *n* is the length of this sequence
  ///   and *m* is the length of the result.
  public func compactMap<T>(_ transform: (Object) throws -> T?) throws -> Object
  where T: Encodable {
    let encoder = ObjectEncoder()

    switch self {
    case .Nil, .Bool, .Int, .Double, .String:
      guard let member = try transform(self) else { return .Nil }
      return try encoder.encode(member)

    case .Array(let value):
      let array: [Object] = try value.compactMap {
        try $0.compactMap(transform) ?? nil
      }

      return array.isEmpty ? .Nil : .Array(array)

    case .JSON(let value):
      let json: JSON = try value.compactMapValues {
        try $0.compactMap(transform) ?? nil
      }

      return json.isEmpty ? .Nil : .JSON(json)
    }
  }
}

extension Object {

  func object(forKey key: String) -> Object {
    guard case .JSON(let json) = self, let value = json[key] else { return .Nil }
    return value
  }

  mutating func set(_ object: Object?, forKey key: String) {
    guard let object = object else { return remove(member: key) }

    switch self {
    case .JSON(var json):
      json[key] = object
      self = .JSON(json)
    default:
      self = .JSON([key: object])
    }
  }

  mutating func set<T>(_ member: T?, forKey key: String) throws where T: Encodable {
    guard let member = member else { return remove(member: key) }

    let encoder = ObjectEncoder()
    let object = try encoder.encode(member)

    switch self {
    case .JSON(var json):
      json[key] = object
      self = .JSON(json)
    default:
      self = .JSON([key: object])
    }
  }

  mutating func remove(member: String) {
    guard case .JSON(var json) = self else { return }
    json.removeValue(forKey: member)
    self = .JSON(json)
  }
}

// MARK: - Object array accessors

extension Object {

  /// Accesses the element of a Object.Array at the specified position.
  ///
  /// The following example uses indexed subscripting to update an array's
  /// second element. After assigning the new value (`"Butler"`) at a specific
  /// position, that value is immediately available at that same position.
  ///
  ///     var streets: Object = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
  ///     streets[1] = "Butler"
  ///     print(streets[1])
  ///     // Prints "Butler"
  ///
  /// - Parameter index: The position of the element to access. `index` must be
  ///   greater than or equal to `startIndex` and less than `endIndex`.
  public subscript(index: Int) -> Object {
    get {
      guard case .Array(let array) = self else { return .Nil }
      return array[index]
    }

    set {
      guard case var .Array(array) = self else { return }
      array[index] = newValue
      self = .Array(array)
    }
  }

}

// MARK: - Object members accessors

extension Object {

  /// Accesses the value associated with the given key for reading and writing
  /// a JSON type.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the JSON type, or `nil` if the key is not found.
  ///
  /// The following example creates a new Object and prints the value of a
  /// key found in the JSON object (`"coral"`) and a key not found in the
  /// dictionary (`"cerise"`).
  ///
  ///     var hues: Object = ["heliotrope": 296, "coral": 16, "aquamarine": 156]
  ///     print(hues["coral"])
  ///     // Prints "Optional(16)"
  ///     print(hues["cerise"])
  ///     // Prints "null"
  ///
  /// When you assign a value for a key and that key already exists, the
  /// JSON object overwrites the existing value. If the JSON object doesn't
  /// contain the key, the key and value are added as a new key-value pair.
  ///
  /// Here, the value for the key `"coral"` is updated from `16` to `18` and a
  /// new key-value pair is added for the key `"cerise"`.
  ///
  ///     hues["coral"] = 18
  ///     print(hues["coral"])
  ///     // Prints "Optional(18)"
  ///
  ///     hues["cerise"] = 330
  ///     print(hues["cerise"])
  ///     // Prints "Optional(330)"
  ///
  /// If you assign `nil` as the value for the given key, the JSON object
  /// removes that key and its associated value.
  ///
  /// In the following example, the key-value pair for the key `"aquamarine"`
  /// is removed from the JSON object by assigning `nil` to the key-based
  /// subscript.
  ///
  ///     hues["aquamarine"] = nil
  ///     print(hues)
  ///     // Prints "["coral": 18, "heliotrope": 296, "cerise": 330]"
  ///
  /// - Parameter key: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the dictionary;
  ///   otherwise, `nil`.
  public subscript(key: String) -> Object? {
    get {
      guard case .JSON(let json) = self, let value = json[key] else { return nil }
      return value
    }

    set { set(newValue, forKey: key) }
  }

  /// Accesses the `Boolean` value associated with the given key for reading.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the JSON type, or `false` if the key is not found.
  ///
  /// - Parameter key: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the JSON;
  ///   otherwise, `false`.
  public subscript<T>(key: String) -> T? where T: Decodable {
    try? object(forKey: key).unwrap()
  }

  /// Accesses the `Boolean` value associated with the given key for reading.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the JSON type, or `false` if the key is not found.
  ///
  /// - Parameter key: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the JSON;
  ///   otherwise, `false`.
  public subscript<T>(key: String) -> T? where T: Codable {
    get { try? object(forKey: key).unwrap() }
    set { try? set(newValue, forKey: key) }
  }
}

extension Optional where Wrapped == Object {

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use the `map` method with a closure that returns a nonoptional value.
  /// This example performs an arithmetic operation on an
  /// optional integer.
  ///
  ///     let possibleNumber: Int? = Int("42")
  ///     let possibleSquare = possibleNumber.map { $0 * $0 }
  ///     print(possibleSquare)
  ///     // Prints "Optional(1764)"
  ///
  ///     let noNumber: Int? = nil
  ///     let noSquare = noNumber.map { $0 * $0 }
  ///     print(noSquare)
  ///     // Prints "nil"
  ///
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  public func map(_ transform: (Wrapped) throws -> Object) throws -> Object? {
    guard case let .some(object) = self else { return nil }
    return try object.map(transform)
  }

  /// Evaluates the given closure when this `Optional` instance is not `nil`,
  /// passing the unwrapped value as a parameter.
  ///
  /// Use the `compactMap` method with a closure that returns an optional value.
  /// This example performs an arithmetic operation with an optional result on
  /// an optional integer.
  ///
  ///     let possibleNumber: Int? = Int("42")
  ///     let nonOverflowingSquare = possibleNumber.compactMap { x -> Int? in
  ///         let (result, overflowed) = x.multipliedReportingOverflow(by: x)
  ///         return overflowed ? nil : result
  ///     } // swiftlint:disable closing_brace_whitespace
  ///     print(nonOverflowingSquare)
  ///     // Prints "Optional(1764)"
  ///
  /// - Parameter transform: A closure that takes the unwrapped value
  ///   of the instance.
  /// - Returns: The result of the given closure. If this instance is `nil`,
  ///   returns `nil`.
  public func compactMap(_ transform: (Wrapped) throws -> Object?) throws -> Object? {
    guard case let .some(object) = self else { return nil }
    return try object.compactMap(transform)
  }
}

// swiftlint:disable closing_brace_whitespace

/// Performs a nil-coalescing operation, returning the wrapped value of an
/// `Object` instance or a default value.
///
/// A nil-coalescing operation unwraps the left-hand side if it has a value, or
/// it returns the right-hand side as a default. The result of this operation
/// will have the non-optional type of the left-hand side's `Decodable` type.
///
/// This operator uses short-circuit evaluation: `object` is checked first,
/// and `defaultValue` is evaluated only if `object` is `.Nil`. For example:
///
///     func getDefault() -> Int {
///         print("Calculating default...")
///         return 42
///     }
///
///     let goodNumber = Object.String("100") ?? getDefault()
///     // goodNumber == 100
///
///     let notSoGoodNumber = Object.String("invalid-input") ?? getDefault()
///     // Prints "Calculating default..."
///     // notSoGoodNumber == 42
///
/// In this example, `goodNumber` is assigned a value of `100` because
/// `Object.String("100")` succeeded in returning a non-`.Nil` result. When
/// `notSoGoodNumber` is initialized, `Object.String("invalid-input")` fails, and
/// so the `getDefault()` method is called to supply a default value.
///
/// - Parameters:
///   - object: An `Object` value.
///   - defaultValue: A value to use as a default. `defaultValue` conforming to `Decodable`.
public func ?? <T>(object: Object, defaultValue: @autoclosure () throws -> T) rethrows -> T
where T: Decodable {
  // swiftlint:disable:previous attributes
  guard object != .Nil else { return try defaultValue() }
  let decoder = ObjectDecoder()
  guard let value = try? decoder.decode(T.self, from: object) else { return try defaultValue() }
  return value
}

// swiftlint:enable closing_brace_whitespace

/// Performs a nil-coalescing operation, returning the wrapped value of an
/// `Object` instance or a default `Decodable` value.
///
/// A nil-coalescing operation unwraps the left-hand side if it has a value, or
/// returns the right-hand side as a default.
///
/// This operator uses short-circuit evaluation: `object` is checked first,
/// and `defaultValue` is evaluated only if `object` is `.Nil`. For example:
///
///     let goodNumber = Object.String("100") ?? Int("42")
///     print(goodNumber)
///     // Prints "Optional(100)"
///
///     let notSoGoodNumber = Object.String("invalid-input") ?? Int("42")
///     print(notSoGoodNumber)
///     // Prints "Optional(42)"
///
/// In this example, `goodNumber` is assigned a value of `100` because
/// `Object.String("100")` succeeds in returning a non-`.Nil` result. When
/// `notSoGoodNumber` is initialized, `Object.String("invalid-input")` fails, and
/// so `Int("42")` is called to supply a default value.
///
/// Because the result of this nil-coalescing operation is itself an optional
/// value, you can chain default values by using `??` multiple times. The
/// first optional value that isn't `nil` stops the chain and becomes the
/// result of the whole expression. The next example tries to find the correct
/// text for a greeting in two separate dictionaries before falling back to a
/// static default.
///
///     let greeting = userPrefs[greetingKey] ??
///         defaults[greetingKey] ?? "Greetings!"
///
/// If `userPrefs[greetingKey]` has a value, that value is assigned to
/// `greeting`. If not, any value in `defaults[greetingKey]` will succeed, and
/// if not that, `greeting` will be set to the non-optional default value,
/// `"Greetings!"`.
///
/// - Parameters:
///   - object: An `Object` value.
///   - defaultValue: A value to use as a default. `defaultValue`.
public func ?? <T>(object: Object, defaultValue: @autoclosure () throws -> T?) rethrows -> T?
where T: Decodable {
  // swiftlint:disable:previous attributes
  guard object != .Nil else { return try defaultValue() }
  let decoder = ObjectDecoder()
  guard let value = try? decoder.decode(T.self, from: object) else { return try defaultValue() }
  return value
}
