// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

extension Order.Comparator where T: ~Copyable {
    /// Returns a comparator that uses this comparator first, then the other
    /// comparator to break ties.
    ///
    /// When this comparator returns `.equal`, the other comparator is used
    /// to determine ordering. Otherwise, this comparator's result is used.
    ///
    /// ```swift
    /// let byNameThenAge = Order.Comparator<Person>
    ///     .by { $0.name }
    ///     .then(.by { $0.age })
    /// ```
    ///
    /// Chaining forms a monoid: it is associative and has an identity element
    /// (the comparator that always returns `.equal`).
    ///
    /// - Parameter other: The comparator to use when this comparator returns `.equal`.
    /// - Returns: A new comparator that chains both comparators.
    @inlinable
    public func then(_ other: Order.Comparator<T>) -> Order.Comparator<T> {
        Order.Comparator { [compare] lhs, rhs in
            compare(lhs, rhs).then(other.compare(lhs, rhs))
        }
    }

    /// Returns a comparator that uses this comparator first, then evaluates
    /// the closure to break ties.
    ///
    /// Lazy variant that avoids computing the secondary comparison when
    /// the primary comparison is decisive.
    ///
    /// ```swift
    /// let comparator = Order.Comparator<Person>
    ///     .by { $0.name }
    ///     .then { .by { $0.expensiveComputation } }
    /// ```
    ///
    /// - Parameter other: A closure that returns the comparator to use when
    ///   this comparator returns `.equal`.
    /// - Returns: A new comparator that chains both comparators lazily.
    @inlinable
    public func then(
        with other: @escaping @Sendable () -> Order.Comparator<T>
    ) -> Order.Comparator<T> {
        Order.Comparator { [compare] lhs, rhs in
            let primary = compare(lhs, rhs)
            if primary.isEqual {
                return other().compare(lhs, rhs)
            }
            return primary
        }
    }
}
