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
    /// A reified comparator that determines the relative order of two values.
    ///
    /// Comparators are first-class values that can be stored, composed, and
    /// passed to sorting functions. They encapsulate comparison logic while
    /// ensuring thread safety through `@Sendable` constraints.
    ///
    /// ## Creating Comparators
    ///
    /// For `Comparison.Protocol` types, use the natural ordering:
    ///
    /// ```swift
    /// let ascending: Ordering.Comparator<Int> = .ascending
    /// let descending: Ordering.Comparator<Int> = .descending
    /// ```
    ///
    /// For custom orderings, use key extraction:
    ///
    /// ```swift
    /// let byAge = Ordering.Comparator<Person>.by { $0.age }
    /// let byName = Ordering.Comparator<Person>.by { $0.name }
    /// ```
    ///
    /// ## Composing Comparators
    ///
    /// Chain comparators for multi-field ordering:
    ///
    /// ```swift
    /// let comparator = Ordering.Comparator<Person>
    ///     .by { $0.department }
    ///     .then(.by { $0.salary }.reversed)
    ///     .then(.by { $0.name })
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// All comparators are `Sendable` and safe for concurrent use across
    /// actor boundaries.
    public struct Comparator<T>: Sendable {
        /// The underlying comparison function.
        @usableFromInline
        internal let compare: @Sendable (T, T) -> Comparison.Result

        /// Creates a comparator from a comparison function.
        ///
        /// - Parameter compare: A function that compares two values and returns
        ///   their relative ordering.
        @inlinable
        public init(_ compare: @escaping @Sendable (T, T) -> Comparison.Result) {
            self.compare = compare
        }

        /// Compares two values using this comparator.
        ///
        /// - Parameters:
        ///   - lhs: The first value to compare.
        ///   - rhs: The second value to compare.
        /// - Returns: The comparison result indicating the relative order.
        @inlinable
        public func callAsFunction(_ lhs: T, _ rhs: T) -> Comparison.Result {
            compare(lhs, rhs)
        }
    }
}
