// DynamicCodingKey.swift
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

/// A `CodingKey` that can be used as a dynamic key for encoding and decoding.
/// Integer-indexed collection is not supported and will be always be convert to string-keyed.
internal struct DynamicCodingKey: CodingKey {

  /// The string to use in a named collection (e.g. a string-keyed dictionary).
  let stringValue: String

  /// The value to use in an integer-indexed collection (e.g. an int-keyed
  /// dictionary).
  let intValue: Int?

  /// Creates a new instance from the given string.
  ///
  /// If the string passed as `stringValue` does not correspond to any instance
  /// of this type, the result is `nil`.
  ///
  /// - parameter stringValue: The string value of the desired key.
  init?(stringValue: String) {
    self.init(stringValue)
  }

  /// Creates a new instance from the specified integer.
  ///
  /// If the value passed as `intValue` does not correspond to any instance of
  /// this type, the result is `nil`.
  ///
  /// - parameter intValue: The integer value of the desired key.
  init?(intValue: Int) {
    self.init("\(intValue)")
  }

  /// Creates a new instance from the given string.
  ///
  /// - parameter stringValue: The string value of the desired key.
  init(_ value: String) {
    self.stringValue = value
    self.intValue = nil
  }
}
