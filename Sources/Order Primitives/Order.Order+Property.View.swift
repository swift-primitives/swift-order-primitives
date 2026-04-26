// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Property_Primitives

// MARK: - Core Methods (require explicit comparator)

extension Property.View where Tag == Order.Order, Base: ~Copyable {

    /// Check if self comes before other using the comparator.
    ///
    /// Returns `true` if `comparator(self, other).isLess`.
    ///
    /// - Parameters:
    ///   - other: The value to compare against.
    ///   - comparator: The comparator defining the ordering.
    /// - Returns: `true` if self comes before other in the specified order.
    @inlinable
    public func isBefore(
        _ other: borrowing Base,
        by comparator: Order.Comparator<Base>
    ) -> Bool {
        unsafe comparator(base.value, other).isLess
    }

    /// Check if self comes after other using the comparator.
    ///
    /// Returns `true` if `comparator(self, other).isGreater`.
    ///
    /// - Parameters:
    ///   - other: The value to compare against.
    ///   - comparator: The comparator defining the ordering.
    /// - Returns: `true` if self comes after other in the specified order.
    @inlinable
    public func isAfter(
        _ other: borrowing Base,
        by comparator: Order.Comparator<Base>
    ) -> Bool {
        unsafe comparator(base.value, other).isGreater
    }

    /// Check if self is equivalent to other using the comparator.
    ///
    /// Returns `true` if `comparator(self, other).isEqual`.
    ///
    /// Note: Equivalence under a comparator may differ from equality.
    /// Two values are equivalent if neither comes before the other.
    ///
    /// - Parameters:
    ///   - other: The value to compare against.
    ///   - comparator: The comparator defining the ordering.
    /// - Returns: `true` if self is equivalent to other under the specified order.
    @inlinable
    public func isEquivalent(
        to other: borrowing Base,
        by comparator: Order.Comparator<Base>
    ) -> Bool {
        unsafe comparator(base.value, other).isEqual
    }
}

// MARK: - Convenience Methods for Comparison.Protocol (use natural ordering)

extension Property.View
where Tag == Order.Order, Base: Comparison.`Protocol` & ~Copyable {

    /// Check if self comes before other using natural ascending order.
    ///
    /// This is a convenience method equivalent to:
    /// ```swift
    /// value.order.isBefore(other, by: .ascending)
    /// ```
    ///
    /// - Parameter other: The value to compare against.
    /// - Returns: `true` if self comes before other in ascending order.
    @inlinable
    public func isBefore(_ other: borrowing Base) -> Bool {
        isBefore(other, by: .ascending)
    }

    /// Check if self comes after other using natural ascending order.
    ///
    /// This is a convenience method equivalent to:
    /// ```swift
    /// value.order.isAfter(other, by: .ascending)
    /// ```
    ///
    /// - Parameter other: The value to compare against.
    /// - Returns: `true` if self comes after other in ascending order.
    @inlinable
    public func isAfter(_ other: borrowing Base) -> Bool {
        isAfter(other, by: .ascending)
    }

    /// Check if self is equivalent to other using natural ordering.
    ///
    /// This is a convenience method equivalent to:
    /// ```swift
    /// value.order.isEquivalent(to: other, by: .ascending)
    /// ```
    ///
    /// - Parameter other: The value to compare against.
    /// - Returns: `true` if self is equivalent to other under natural ordering.
    @inlinable
    public func isEquivalent(to other: borrowing Base) -> Bool {
        isEquivalent(to: other, by: .ascending)
    }
}
