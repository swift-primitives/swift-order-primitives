// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives

extension Ordering.Comparator {
    /// Creates a comparator using a key-extracting function.
    ///
    /// The comparator extracts the key from each value and compares
    /// the keys using their natural ordering.
    ///
    /// ```swift
    /// let byAge = Ordering.Comparator<Person>.by { $0.age }
    /// let byName = Ordering.Comparator<Person>.by { $0.name }
    /// ```
    ///
    /// - Note: KeyPath-based overloads (`.by(\.age)`) are not provided because
    ///   `KeyPath` is not `Sendable` in Swift 6. Use closure syntax instead.
    ///
    /// - Parameter selector: A function that extracts the comparable key
    ///   from a value.
    /// - Returns: A comparator that orders values by their extracted keys.
    @inlinable
    public static func by<Value: Comparison.`Protocol`>(
        _ selector: @escaping @Sendable (T) -> Value
    ) -> Ordering.Comparator<T> {
        Ordering.Comparator { lhs, rhs in
            let lhsValue = selector(lhs)
            let rhsValue = selector(rhs)
            if lhsValue < rhsValue {
                return .less
            } else if lhsValue > rhsValue {
                return .greater
            } else {
                return .equal
            }
        }
    }

    /// Creates a comparator using a key-extracting function and custom comparator.
    ///
    /// The comparator extracts the key from each value and compares
    /// the keys using the provided comparator.
    ///
    /// ```swift
    /// let byNameCaseInsensitive = Ordering.Comparator<Person>.by(
    ///     { $0.name.lowercased() },
    ///     using: .ascending
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - selector: A function that extracts the key from a value.
    ///   - comparator: The comparator to use for comparing extracted keys.
    /// - Returns: A comparator that orders values by their extracted keys
    ///   using the specified comparator.
    @inlinable
    public static func by<Value>(
        _ selector: @escaping @Sendable (T) -> Value,
        using comparator: Ordering.Comparator<Value>
    ) -> Ordering.Comparator<T> {
        Ordering.Comparator { lhs, rhs in
            comparator(selector(lhs), selector(rhs))
        }
    }
}
