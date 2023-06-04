// Object.swift
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

/// JSON object.
public typealias JSON = [String: Object]

/// A versatile response object
///
/// - Nil: Null value.
/// - Bool: Boolean value.
/// - Int: Integer value.
/// - Double: Double value.
/// - String: String value.
/// - Array: Array of object.
/// - Date: Date value.
/// - JSON: Json object.
@dynamicMemberLookup  // swiftlint:disable:this missing_docs
public enum Object {

  case Nil
  case Bool(Bool)
  case Int(Int64)
  case Double(Double)
  case String(String)
  case Array([Object])
  case JSON(JSON)

  init() {
    self = .Nil
  }

  init(_ block: (inout Object) -> Void) {
    var object: Object = .Nil
    block(&object)
    self = object
  }

  /// Accesses the value associated with the given key for reading and writing
  /// a JSON type.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the JSON type, or `.Nil` if the key is not found.
  ///
  /// The following example creates a new Object and prints the value of a
  /// key found in the JSON object (`"coral"`) and a key not found in the
  /// dictionary (`"cerise"`).
  ///
  ///     var hues: Object = ["heliotrope": 296, "coral": 16, "aquamarine": 156]
  ///     print(hues.coral)
  ///     // Prints "16"
  ///     print(hues.cerise)
  ///     // Prints "null"
  ///
  /// When you assign a value for a key and that key already exists, the
  /// JSON object overwrites the existing value. If the JSON object doesn't
  /// contain the key, the key and value are added as a new key-value pair.
  ///
  /// Here, the value for the key `"coral"` is updated from `16` to `18` and a
  /// new key-value pair is added for the key `"cerise"`.
  ///
  ///     hues.coral = 18
  ///     print(hues.coral)
  ///     // Prints "18"
  ///
  ///     hues.cerise = 330
  ///     print(hues.cerise)
  ///     // Prints "330"
  ///
  /// If you assign `nil` as the value for the given key, the JSON object
  /// removes that key and its associated value.
  ///
  /// In the following example, the key-value pair for the key `"aquamarine"`
  /// is removed from the JSON object by assigning `nil` to the key-based
  /// subscript.
  ///
  ///     hues.aquamarine = nil
  ///     print(hues)
  ///     // Prints "["coral": 18, "heliotrope": 296, "cerise": 330]"
  ///
  /// - Parameter member: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the JSON;
  ///   otherwise, `.Nil`.
  public subscript(dynamicMember member: String) -> Object {
    get { return self[member] ?? .Nil }
    set { self[member] = newValue }
  }

  /// Accesses a member value associated with the given key for reading.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the Object, or `nil` if the key with `T` value is not found.
  ///
  /// - Parameter member: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the JSON;
  ///   otherwise, `nil`.
  public subscript<T>(dynamicMember member: String) -> T? where T: Decodable {
    return self[member]
  }

  /// Accesses a member value associated with the given key for reading.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the Object, or `nil` if the key with `T` value is not found.
  ///
  /// - Parameter member: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the JSON;
  ///   otherwise, `nil`.
  public subscript<T>(dynamicMember member: String) -> T? where T: Codable {
    get { return self[member] }
    set { self[member] = newValue }
  }
}

// MARK: - ExpressibleByNilLiteral extension

extension Object: ExpressibleByNilLiteral {

  /// Creates an instance initialized with `nil`.
  public init(nilLiteral: ()) {
    self = .Nil
  }

}

// MARK: - ExpressibleByBooleanLiteral extension

extension Object: ExpressibleByBooleanLiteral {

  /// Creates an instance initialized to the given Boolean value.
  ///
  /// Do not call this initializer directly. Instead, initialize a variable or
  /// constant using one of the Boolean literals `true` and `false`. For
  /// example:
  ///
  ///     let object: Object = true
  ///
  /// In this example, the assignment to the `object` constant calls this
  /// Boolean literal initializer behind the scenes.
  ///
  /// - Parameter value: The value of the new instance.
  public init(booleanLiteral value: Bool) {
    self = .Bool(value)
  }

}

// MARK: - ExpressibleByIntegerLiteral extension

extension Object: ExpressibleByIntegerLiteral {

  /// Creates an instance initialized to the specified integer value.
  ///
  /// Do not call this initializer directly. Instead, initialize a variable or
  /// constant using an integer literal. For example:
  ///
  ///     let object: Object = 23
  ///
  /// In this example, the assignment to the `object` constant calls this integer
  /// literal initializer behind the scenes.
  ///
  /// - Parameter value: The value to create.
  public init(integerLiteral value: Int) {
    self = .Int(.init(value))
  }

}

// MARK: - ExpressibleByFloatLiteral extension

extension Object: ExpressibleByFloatLiteral {

  /// Creates an instance initialized to the specified floating-point value.
  ///
  /// Do not call this initializer directly. Instead, initialize a variable or
  /// constant using a floating-point literal. For example:
  ///
  ///     let object: Object = 21.5
  ///
  /// In this example, the assignment to the `object` constant calls this
  /// floating-point literal initializer behind the scenes.
  ///
  /// - Parameter value: The value to create.
  public init(floatLiteral value: Double) {
    self = .Double(value)
  }

}

// MARK: - ExpressibleByStringLiteral extension

extension Object: ExpressibleByStringLiteral {

  /// Creates an instance initialized to the given string value.
  ///
  /// - Parameter value: The value of the new instance.
  public init(stringLiteral value: String) {
    self = .String(value)
  }
}

// MARK: - ExpressibleByArrayLiteral extension

extension Object: ExpressibleByArrayLiteral {

  /// Creates an instance initialized with the given elements.
  public init(arrayLiteral elements: Object...) {
    self = .Array(elements)
  }
}

// MARK: - ExpressibleByDictionaryLiteral extension

extension Object: ExpressibleByDictionaryLiteral {

  /// Creates an instance initialized with the given key-value pairs.
  public init(dictionaryLiteral elements: (String, Object)...) {
    var json = [Swift.String: Object]()

    for (key, object) in elements {
      json[key] = object
    }

    self = .JSON(json)
  }
}

// MARK: - Sequence extension

extension Object: Sequence {

  /// The first member.
  public var first: Object {
    get {
      guard case .Array(let array) = self else { return object(forKey: #function) }
      return array.first ?? .Nil
    }

    set { set(newValue, forKey: #function) }
  }

  /// The last member.
  public var last: Object {
    get {
      guard case .Array(let array) = self else { return object(forKey: #function) }
      return array.last ?? .Nil
    }

    set { set(newValue, forKey: #function) }
  }

  // swiftlint:disable closing_brace_whitespace

  /// A Boolean value indicating whether the Object is empty.
  ///
  /// When you need to check whether your Object is empty, use the
  /// `isEmpty` property.
  ///
  ///     let horseName: Object = "Silver"
  ///     if horseName.isEmpty {
  ///         print("I've been through the desert on a horse with no name.")
  ///     } else {
  ///         print("Hi ho, \(horseName)!")
  ///     }
  ///     // Prints "Hi ho, Silver!")
  ///
  /// - Complexity: O(1)
  public var isEmpty: Bool {
    get {
      switch self {
      case .String(let string):
        return string.isEmpty
      case .Array(let array):
        return array.isEmpty
      case .JSON(let json):
        return self[#function] ?? json.isEmpty
      default:
        return true
      }
    }

    set { set(.Bool(newValue), forKey: #function) }
  }

  // swiftlint:enable closing_brace_whitespace

  /// The number of elements in the object.
  /// Count will return 0 if the object is a primary type.
  public var count: Int {
    get {
      switch self {
      case .String(let string):
        return string.count
      case .Array(let array):
        return array.count
      case .JSON(let json):
        return self[#function] ?? json.count
      default:
        return 0
      }
    }

    set { set(.Int(.init(newValue)), forKey: #function) }
  }

  /// The number of elements in the object.
  /// Count will return 0 if the object is a primary type.
  public var underestimatedCount: Int {
    get {
      switch self {
      case .String(let string):
        return string.underestimatedCount
      case .Array(let array):
        return array.underestimatedCount
      case .JSON(let json):
        return self[#function] ?? json.underestimatedCount
      default:
        return 0
      }
    }

    set { set(.Int(.init(newValue)), forKey: #function) }
  }

  /// Returns an iterator over the elements of this sequence.
  public func makeIterator() -> AnyIterator<(key: String?, object: Object)> {

    switch self {
    case .JSON(let json):
      var iterator = json.makeIterator()
      return AnyIterator {
        guard let next = iterator.next() else { return nil }
        return (next.key, next.value)
      }

    case .Array(let array):
      var iterator = array.makeIterator()
      return AnyIterator {
        guard let next = iterator.next() else { return nil }
        return (nil, next)
      }

    case .String(let string):
      var iterator = string.makeIterator()
      return AnyIterator {
        guard let next = iterator.next() else { return nil }
        return (nil, .String("\(next)"))
      }

    default:
      return AnyIterator { return nil }
    }
  }
}

// MARK: - CustomStringConvertible extension

extension Object: CustomStringConvertible {

  /// A textual representation of this object.
  public var description: String {
    switch self {
    case .Nil:
      return "(null)"
    case .Bool(let value):
      return Swift.String(describing: value)
    case .Int(let value):
      return Swift.String(describing: value)
    case .Double(let value):
      return Swift.String(describing: value)
    case .String(let value):
      return Swift.String(describing: value)
    case .Array(let value):
      return Swift.String(describing: value)
    case .JSON(let value):
      let encoder = JSONEncoder()
      guard
        let data = try? encoder.encode(value),
        let description = Swift.String(data: data, encoding: .utf8)
      else { return "{}" }
      return description
    }
  }
}

// MARK: - CustomDebugStringConvertible extension

extension Object: CustomDebugStringConvertible {

  /// A textual representation suitable for debugging
  /// purposes
  public var debugDescription: String {
    get {
      switch self {
      case .Nil:
        return "(null)"
      case .Bool(let value):
        return Swift.String(reflecting: value)
      case .Int(let value):
        return Swift.String(reflecting: value)
      case .Double(let value):
        return Swift.String(reflecting: value)
      case .String(let value):
        return Swift.String(reflecting: value)
      case .Array(let value):
        return Swift.String(reflecting: value)
      case .JSON(let value):
        return self[#function]
          ?? {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            guard
              let data = try? encoder.encode(value),
              let pretty = Swift.String(data: data, encoding: .utf8)
            else { return "{}" }
            return pretty
          }()
      }
    }
    set { set(.String(newValue), forKey: #function) }

  }
}

// MARK: - Equatable extension

extension Object: Equatable {

  /// Returns a Boolean value indicating whether two objects are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func == (lhs: Object, rhs: Object) -> Bool {
    switch (lhs, rhs) {
    case (.Nil, .Nil):
      return true
    case (.Bool(let lhs), .Bool(let rhs)):
      return lhs == rhs
    case (.Int(let lhs), .Int(let rhs)):
      return lhs == rhs
    case (.Double(let lhs), .Double(let rhs)):
      return lhs == rhs
    case (.String(let lhs), .String(let rhs)):
      return lhs == rhs
    case (.Array(let lhs), .Array(let rhs)):
      return lhs == rhs
    case (.JSON(let lhs), .JSON(let rhs)):
      return lhs == rhs
    default:
      return false
    }
  }
}
