// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Comparison_Primitives
public import Order_Direction_Primitives

extension Order {
    /// A projection that extracts an orderable value from a root type.
    ///
    /// Projections can be composed and transformed before being converted
    /// to comparators, enabling flexible ordering specifications.
    ///
    /// ## Creating Projections
    ///
    /// ```swift
    /// let byAge = Order.Projection<Person, Int>(
    ///     { $0.age },
    ///     direction: .descending
    /// )
    /// ```
    ///
    /// ## Converting to Comparator
    ///
    /// ```swift
    /// let comparator = byAge.comparator
    /// ```
    ///
    /// - Note: KeyPath-based initializers are not provided because `KeyPath`
    ///   is not `Sendable` in Swift 6. Use closure syntax instead.
    ///
    /// ## Move-Only Support
    ///
    /// Projections support `~Copyable` types for both root and value:
    ///
    /// ```swift
    /// struct Token: ~Copyable, Comparison.Protocol { let id: Int; ... }
    /// let byId = Order.Projection<Token, Token> { $0 }
    /// ```
    public struct Projection<Root: ~Copyable, Value: Comparison.`Protocol` & ~Copyable>: Sendable {
        /// The key extraction function.
        @usableFromInline
        internal let extract: @Sendable (borrowing Root) -> Value

        /// The direction of ordering.
        public let direction: Direction

        /// Creates a projection with the given extractor and direction.
        ///
        /// - Parameters:
        ///   - extract: A function that extracts the comparable value from
        ///     an instance of the root type.
        ///   - direction: The direction of ordering. Defaults to `.ascending`.
        @inlinable
        public init(
            _ extract: @escaping @Sendable (borrowing Root) -> Value,
            direction: Direction = .ascending
        ) {
            self.extract = extract
            self.direction = direction
        }

    }
}

extension Order.Projection where Root: ~Copyable, Value: Comparison.`Protocol` & ~Copyable {
    /// Returns a projection with reversed direction.
    ///
    /// - `.ascending` becomes `.descending`
    /// - `.descending` becomes `.ascending`
    @inlinable
    public var reversed: Self {
        Self(extract, direction: direction.reversed)
    }

    /// Converts this projection to a comparator.
    ///
    /// The resulting comparator extracts the value using this projection's
    /// extractor and compares using the projection's direction.
    @inlinable
    public var comparator: Order.Comparator<Root> {
        let base = Order.Comparator<Root>.by(extract)
        return direction == .ascending ? base : base.reversed
    }
}
