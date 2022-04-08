// ObjectMember.swift
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

/// A type that can decode itself from an `Object` representation.
protocol ObjectDecodable {

    /// Creates a new instance by decoding from the given `Object`.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws
}

/// A type that can encode itself to an `Object` representation.
protocol ObjectEncodable {

    /// Encodes this value into an `Object`.
    /// - Parameter path: The coding path to this member,
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws
}

/// A type that can convert itself into and out of an `Object` representation.
///
/// `ObjectMember` is a type alias for the `ObjectDecodable` and `ObjectEncodable` protocols.
/// When you use `ObjectMember` as a type or a generic constraint, it matches
/// any type that conforms to both protocols.
typealias ObjectMember = ObjectDecodable & ObjectEncodable

// MARK: - Convert Boolean

extension Bool: ObjectMember {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        switch container.object {
        case .Bool(let value):
            self = value
        case .Int(let value):
            self = value != 0
        case .Double(let value):
            self = value != 0
        case .String(let value):
            guard let bool = Bool(value) else { throw DecodingError.dataConversionError(to: Self.self, in: container) }
            self = bool
        default:
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
    }

    /// Converts to .Bool object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        container.object = .Bool(self)
    }

}

// MARK: - Convert Integer

extension ObjectDecodable where Self: BinaryInteger {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        switch container.object {
        case .Bool(let value):
            self = value ? 1 : 0
        case .Int(let value):
            self.init(value)
        case .Double(let value):
            self.init(value)
        case .String(let value):
            guard let int = Int(value) else { throw DecodingError.dataConversionError(to: Self.self, in: container) }
            self.init(int)
        default:
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
    }

}

extension ObjectEncodable where Self: BinaryInteger {

    /// Convert to .Int object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        let value = Int64(self)
        container.object = .Int(value)
    }
}

extension Int: ObjectMember { }

extension Int8: ObjectMember { }

extension Int16: ObjectMember { }

extension Int32: ObjectMember { }

extension Int64: ObjectMember { }

extension UInt: ObjectMember { }

extension UInt8: ObjectMember { }

extension UInt16: ObjectMember { }

extension UInt32: ObjectMember { }

extension UInt64: ObjectMember { }

// MARK: - Convert Floating

extension ObjectDecodable where Self: BinaryFloatingPoint {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        switch container.object {
        case .Bool(let value):
            self = value ? 1 : 0
        case .Int(let value):
            self.init(value)
        case .Double(let value):
            self.init(value)
        case .String(let value):
            guard let int = Double(value) else { 
                throw DecodingError.dataConversionError(to: Self.self, in: container) 
            }
            self.init(int)
        case .Date(let value):
            self.init(value.timeIntervalSince1970)
        default:
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
    }

}

extension ObjectEncodable where Self: BinaryFloatingPoint {

    /// Convert to .Double object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        let value = Double(self)
        container.object = .Double(value)
    }

}

extension Double: ObjectMember { }

extension Float: ObjectMember { }

// MARK: - Convert String

extension String: ObjectMember {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        switch container.object {
        case .Bool, .Int, .Double, .String, .Date:
            self = String(describing: container.object)
        default:
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
    }

    /// Convert to .String object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        container.object = .String(self)
    }

}

// MARK: - Convert Date

extension Date: ObjectMember {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        switch container.object {
        case .Date(let value):
            self = value
        default:
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
    }

    /// Convert to .Date object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        container.object = .Date(self)
    }

}

// MARK: - Convert Date

extension Data: ObjectMember {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        guard 
            case let .String(value) = container.object,
            let data = Data(base64Encoded: value, options: .ignoreUnknownCharacters)
        else {
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
        self = data
    }

    /// Convert to .Date object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        container.object = .String(base64EncodedString())
    }

}

// MARK: - Convert Enum

extension ObjectDecodable where Self: RawRepresentable, Self.RawValue: ObjectDecodable {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        let rawValue = try RawValue(from: container)
        guard let value = Self(rawValue: rawValue) else {
            throw DecodingError.dataConversionError(to: Self.self, in: container)
        }
        self = value
    }

}

extension ObjectEncodable where Self: RawRepresentable, Self.RawValue: ObjectEncodable {

    /// Convert to object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        try rawValue.encode(to: container)
    }

}

// MARK: - Convert URL

extension URL: ObjectMember {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        guard
            case let .String(value) = container.object,
            let url = URL(string: value)
        else { throw DecodingError.dataConversionError(to: Self.self, in: container) }
        self = url
    }

    /// Convert to .String object.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        container.object = .String(absoluteString)
    }

}

// MARK: - Convert Object

extension Object: ObjectMember {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        self = container.object
    }

    /// Returns self.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        container.object = self
    }
}

// MARK: - Convert Optional

extension Optional: ObjectDecodable where Wrapped: ObjectDecodable {

    /// Creates from an object.
    ///
    /// - Parameter container: containing the `Object` to decode.
    /// - throws: `DecodingError.dataCorruptedError` if the encountered object
    ///   is invalid.
    init(from container: ObjectMemberDecoder.SingleValueContainer) throws {
        switch container.object {
        case .Nil:
            self = .none
        default:
            self = try Wrapped(from: container)
        }
    }

}

extension Optional: ObjectEncodable where Wrapped: ObjectEncodable {

    /// Returns self.
    func encode(to container: ObjectMemberEncoder.SingleValueContainer) throws {
        switch self {
        case .none:
            container.object = .Nil
        case .some(let value):
            try value.encode(to: container)
        }
    }
}
