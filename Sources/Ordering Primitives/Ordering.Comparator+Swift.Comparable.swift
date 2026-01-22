// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives

extension Ordering.Comparator where T: Swift.Comparable {
    /// Creates a comparator using the natural ordering of a `Swift.Comparable` type.
    ///
    /// This initializer bridges `Swift.Comparable` types to `Ordering.Comparator`,
    /// enabling use with standard library types like `Int`, `String`, and `Double`.
    ///
    /// ```swift
    /// let intComparator = Ordering.Comparator<Int>(swift: ())
    /// intComparator(1, 2)  // .less
    /// intComparator(2, 2)  // .equal
    /// intComparator(3, 2)  // .greater
    /// ```
    @inlinable
    public init(swift: Void) {
        self.init { lhs, rhs in
            Comparison.Result(comparing: lhs, to: rhs)
        }
    }

    /// The natural ascending comparator for `Swift.Comparable` types.
    ///
    /// Smaller values are ordered before larger values.
    ///
    /// ```swift
    /// let comparator: Ordering.Comparator<Int> = .swiftAscending
    /// comparator(1, 2)  // .less
    /// ```
    @inlinable
    public static var swiftAscending: Ordering.Comparator<T> {
        Ordering.Comparator(swift: ())
    }

    /// The natural descending comparator for `Swift.Comparable` types.
    ///
    /// Larger values are ordered before smaller values.
    ///
    /// ```swift
    /// let comparator: Ordering.Comparator<Int> = .swiftDescending
    /// comparator(1, 2)  // .greater
    /// ```
    @inlinable
    public static var swiftDescending: Ordering.Comparator<T> {
        Ordering.Comparator(swift: ()).reversed
    }
}

extension Ordering.Comparator {
    /// Creates a comparator using a key-extracting function for `Swift.Comparable` keys.
    ///
    /// This method bridges `Swift.Comparable` keys to `Ordering.Comparator`,
    /// enabling key extraction with standard library types.
    ///
    /// ```swift
    /// let byAge = Ordering.Comparator<Person>.swiftBy { $0.age }
    /// ```
    ///
    /// - Parameter selector: A function that extracts the comparable key from a value.
    /// - Returns: A comparator that orders values by their extracted keys.
    @inlinable
    public static func swiftBy<Value: Swift.Comparable>(
        _ selector: @escaping @Sendable (borrowing T) -> Value
    ) -> Ordering.Comparator<T> {
        Ordering.Comparator { lhs, rhs in
            Comparison.Result(comparing: selector(lhs), to: selector(rhs))
        }
    }
}
