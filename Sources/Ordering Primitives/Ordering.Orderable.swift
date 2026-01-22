// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Property_Primitives

extension Ordering {
    /// A type that can participate in fluent ordering comparisons.
    ///
    /// Conforming to `Orderable` provides the `.order` property, enabling
    /// fluent APIs for checking relative ordering using comparators.
    ///
    /// ## Conformance
    ///
    /// Types opt into `Orderable` by declaring conformance:
    ///
    /// ```swift
    /// struct Person: Ordering.Orderable {
    ///     let name: String
    ///     let age: Int
    /// }
    /// ```
    ///
    /// ## Usage
    ///
    /// Once conforming, use `.order` with a comparator:
    ///
    /// ```swift
    /// let byAge = Ordering.Comparator<Person> { lhs, rhs in
    ///     Comparison.Result(comparing: lhs.age, to: rhs.age)
    /// }
    ///
    /// var alice = Person(name: "Alice", age: 30)
    /// let bob = Person(name: "Bob", age: 25)
    ///
    /// alice.order.isBefore(bob, by: byAge)     // false
    /// alice.order.isAfter(bob, by: byAge)      // true
    /// alice.order.isEquivalent(to: bob, by: byAge)  // false
    /// ```
    ///
    /// ## Comparison.Protocol Types
    ///
    /// Types conforming to both `Orderable` and `Comparison.Protocol` gain
    /// convenience methods that use natural ascending order:
    ///
    /// ```swift
    /// struct Token: Ordering.Orderable, Comparison.`Protocol` {
    ///     let id: Int
    ///
    ///     static func < (lhs: borrowing Token, rhs: borrowing Token) -> Bool {
    ///         lhs.id < rhs.id
    ///     }
    ///
    ///     static func == (lhs: borrowing Token, rhs: borrowing Token) -> Bool {
    ///         lhs.id == rhs.id
    ///     }
    /// }
    ///
    /// var a = Token(id: 5)
    /// let b = Token(id: 10)
    ///
    /// a.order.isBefore(b)  // true (uses natural ascending order)
    /// ```
    public protocol Orderable: ~Copyable {}
}

extension Ordering.Orderable where Self: ~Copyable {
    /// Access fluent ordering APIs.
    ///
    /// The `.order` property provides methods for checking relative ordering
    /// of values using comparators.
    ///
    /// ## Methods
    ///
    /// - `isBefore(_:by:)`: Check if self comes before other
    /// - `isAfter(_:by:)`: Check if self comes after other
    /// - `isEquivalent(to:by:)`: Check if self is equivalent to other
    ///
    /// For `Comparison.Protocol` types, convenience methods without the
    /// `by:` parameter use natural ascending order.
    public var order: Property<Ordering.Order, Self>.View {
        mutating _read {
            yield unsafe Property<Ordering.Order, Self>.View(&self)
        }
    }
}
