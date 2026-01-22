// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives

extension Ordering {
    /// A comparator for partially ordered types.
    ///
    /// Unlike ``Comparator`` which always returns a result, `PartialComparator`
    /// returns `nil` when two values are incomparable. This is useful for
    /// types with partial orders, such as floating-point numbers where
    /// NaN is incomparable with any value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let floatComparator = Ordering.PartialComparator<Double> { lhs, rhs in
    ///     guard !lhs.isNaN && !rhs.isNaN else { return nil }
    ///     return Comparison.Result(lhs, rhs)
    /// }
    ///
    /// floatComparator(1.0, 2.0)       // .some(.less)
    /// floatComparator(Double.nan, 1.0) // nil (incomparable)
    /// ```
    public struct PartialComparator<T>: Sendable {
        /// The underlying comparison function.
        @usableFromInline
        internal let compare: @Sendable (T, T) -> Comparison.Result?

        /// Creates a partial comparator from a comparison function.
        ///
        /// - Parameter compare: A function that compares two values and returns
        ///   their relative ordering, or `nil` if they are incomparable.
        @inlinable
        public init(_ compare: @escaping @Sendable (T, T) -> Comparison.Result?) {
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
        public func callAsFunction(_ lhs: T, _ rhs: T) -> Comparison.Result? {
            compare(lhs, rhs)
        }
    }
}
