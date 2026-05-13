// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives

// Pre-SE-0499 only. On Swift 6.4+ `Comparison.`Protocol`` is a typealias to
// `Swift.Comparable` (per swift-comparison-primitives' Comparison.Protocol.swift);
// the `Comparison.`Protocol` & ~Copyable` extension in
// Order.Comparator+Comparable.swift then supplies `ascending` / `descending`
// for Swift.Comparable types and the `.by(_:)` overload on
// Order.Comparator+Projection.swift supplies the key-extracting form. A
// parallel Swift.Comparable extension here would collide as a redeclaration
// under 6.4.
//
// On Swift <6.4 the two protocols are disjoint, so this parallel surface is
// needed to bridge stdlib `Swift.Comparable` types (Int, UInt8, …) into
// `Order.Comparator`. Methods carry `@_disfavoredOverload` to defer to
// Comparison.Protocol for types that conform to both.
#if swift(<6.4)
    extension Order.Comparator where T: Swift.Comparable {
        /// The natural ascending comparator for `Swift.Comparable` types.
        ///
        /// Smaller values are ordered before larger values.
        ///
        /// ```swift
        /// let comparator: Order.Comparator<Int> = .ascending
        /// comparator(1, 2)  // .less
        /// ```
        ///
        /// - Note: For `~Copyable` types, conform to `Comparison.Protocol` instead.
        @_disfavoredOverload
        @inlinable
        public static var ascending: Order.Comparator<T> {
            nonisolated(unsafe) let _: T.Type = T.self
            return Order.Comparator { lhs, rhs in
                Comparison(comparing: lhs, to: rhs)
            }
        }

        /// The natural descending comparator for `Swift.Comparable` types.
        ///
        /// Larger values are ordered before smaller values.
        ///
        /// ```swift
        /// let comparator: Order.Comparator<Int> = .descending
        /// comparator(1, 2)  // .greater
        /// ```
        ///
        /// - Note: For `~Copyable` types, conform to `Comparison.Protocol` instead.
        @_disfavoredOverload
        @inlinable
        public static var descending: Order.Comparator<T> {
            ascending.reversed
        }
    }

    extension Order.Comparator {
        /// Creates a comparator using a key-extracting function for `Swift.Comparable` keys.
        ///
        /// ```swift
        /// let byAge = Order.Comparator<Person>.by { $0.age }
        /// ```
        ///
        /// - Parameter selector: A function that extracts the comparable key from a value.
        /// - Returns: A comparator that orders values by their extracted keys.
        ///
        /// - Note: For `~Copyable` key types, conform them to `Comparison.Protocol` instead.
        @_disfavoredOverload
        @inlinable
        public static func by<Value: Swift.Comparable>(
            _ selector: @escaping @Sendable (borrowing T) -> Value
        ) -> Order.Comparator<T> {
            nonisolated(unsafe) let _: Value.Type = Value.self
            return Order.Comparator { lhs, rhs in
                Comparison(comparing: selector(lhs), to: selector(rhs))
            }
        }
    }
#endif
