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
    /// A comparator for partially ordered types.
    ///
    /// Unlike ``Ordering/Comparator`` which always returns a result, `Partial`
    /// returns `nil` when two values are incomparable. This is useful for
    /// types with partial orders, such as floating-point numbers where
    /// NaN is incomparable with any value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let comparator = Ordering.Comparator<Double>.Partial { lhs, rhs in
    ///     guard !lhs.isNaN && !rhs.isNaN else { return nil }
    ///     return Comparison(lhs, rhs)
    /// }
    ///
    /// comparator(1.0, 2.0)       // .some(.less)
    /// comparator(Double.nan, 1.0) // nil (incomparable)
    /// ```
    ///
    /// ## Move-Only Support
    ///
    /// Partial comparators support `~Copyable` types via `borrowing` parameters.
    public struct Partial: Sendable {
        /// The underlying comparison function.
        @usableFromInline
        internal let compare: @Sendable (borrowing T, borrowing T) -> Comparison?

        /// Creates a partial comparator from a comparison function.
        ///
        /// - Parameter compare: A function that compares two values and returns
        ///   their relative ordering, or `nil` if they are incomparable.
        @inlinable
        public init(_ compare: @escaping @Sendable (borrowing T, borrowing T) -> Comparison?) {
            self.compare = compare
        }

        /// Compares two values using this partial comparator.
        ///
        /// - Parameters:
        ///   - lhs: The first value to compare.
        ///   - rhs: The second value to compare.
        /// - Returns: The comparison result indicating the relative order,
        ///   or `nil` if the values are incomparable.
        @inlinable
        public func callAsFunction(_ lhs: borrowing T, _ rhs: borrowing T) -> Comparison? {
            compare(lhs, rhs)
        }
    }
}
