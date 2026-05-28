// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives

extension Order.Comparator where T: Comparison.`Protocol` & ~Copyable {
    /// Creates a comparator using the natural ordering of a `Comparison.Protocol` type.
    ///
    /// ```swift
    /// let intComparator = Order.Comparator<Int>()
    /// intComparator(1, 2)  // .less
    /// intComparator(2, 2)  // .equal
    /// intComparator(3, 2)  // .greater
    /// ```
    @inlinable
    public init() {
        nonisolated(unsafe) let _: T.Type = T.self
        self.init { lhs, rhs in
            Comparison(lhs, rhs)
        }
    }

    /// The natural ascending comparator for `Comparison.Protocol` types.
    ///
    /// Smaller values are ordered before larger values.
    ///
    /// ```swift
    /// let comparator: Order.Comparator<Int> = .ascending
    /// comparator(1, 2)  // .less
    /// ```
    @inlinable
    public static var ascending: Order.Comparator<T> {
        Order.Comparator()
    }

    /// The natural descending comparator for `Comparison.Protocol` types.
    ///
    /// Larger values are ordered before smaller values.
    ///
    /// ```swift
    /// let comparator: Order.Comparator<Int> = .descending
    /// comparator(1, 2)  // .greater
    /// ```
    @inlinable
    public static var descending: Order.Comparator<T> {
        Order.Comparator().reversed
    }
}
