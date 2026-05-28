// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives

extension Order.Comparator where T: ~Copyable {
    /// Returns a comparator with reversed ordering.
    ///
    /// Elements that were ordered as less become greater, and vice versa.
    /// Equal elements remain equal.
    ///
    /// ```swift
    /// let ascending: Order.Comparator<Int> = .ascending
    /// let descending = ascending.reversed
    ///
    /// ascending(1, 2)   // .less
    /// descending(1, 2)  // .greater
    /// ```
    ///
    /// Reversal is an involution: `comparator.reversed.reversed` equals
    /// the original comparator in behavior.
    @inlinable
    public var reversed: Order.Comparator<T> {
        Order.Comparator { [compare] lhs, rhs in
            compare(lhs, rhs).reversed
        }
    }
}
