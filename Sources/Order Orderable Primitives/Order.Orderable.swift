// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Property_Primitives

extension Order {
    /// A type that can participate in fluent ordering comparisons.
    ///
    /// Conforming to `Orderable` provides the `.order` property, enabling
    /// fluent APIs for checking relative ordering using comparators.
    ///
    /// ## Extrinsic vs Intrinsic Orderability
    ///
    /// `Order.Orderable` is the **extrinsic** orderability complement to
    /// `Comparison.Protocol`'s **intrinsic** total order:
    ///
    /// - `Comparison.Protocol` declares that a type *has an intrinsic order* —
    ///   the type itself defines what "less than" means (`<`/`==`), so any two
    ///   values are comparable without external input.
    /// - `Order.Orderable` declares only that a type *can be ordered by a
    ///   supplied `Order.Comparator`*. The ordering lives outside the type: a
    ///   conformer needs no intrinsic order of its own, and the same value can
    ///   be ordered different ways by different comparators (by age, by name, …).
    ///
    /// This is why `Orderable` is an empty marker protocol — it imposes no
    /// requirements on the conformer beyond eligibility for the `.order`
    /// fluent accessor. The order is brought *to* the value via a comparator,
    /// rather than being a property *of* the value.
    ///
    /// Conforming to **both** `Order.Orderable` and `Comparison.Protocol`
    /// unlocks the natural-ascending-order convenience methods (the `.order`
    /// methods that omit the `by:` comparator parameter): the intrinsic order
    /// supplied by `Comparison.Protocol` is used as the implicit comparator.
    ///
    /// ## Conformance
    ///
    /// Types opt into `Orderable` by declaring conformance:
    ///
    /// ```swift
    /// struct Person: Order.Orderable {
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
    /// let byAge = Order.Comparator<Person> { lhs, rhs in
    ///     Comparison(comparing: lhs.age, to: rhs.age)
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
    /// struct Token: Order.Orderable, Comparison.`Protocol` {
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

extension Order.Orderable where Self: ~Copyable {
    /// Access fluent ordering APIs.
    ///
    /// The `.order` property provides methods for checking relative ordering
    /// of values using comparators. Ordering is **extrinsic**: the relation is
    /// supplied by the `Order.Comparator` passed to each method, not held by
    /// the value itself — so a single value can be ordered different ways by
    /// different comparators.
    ///
    /// ## Methods
    ///
    /// - `isBefore(_:by:)`: Check if self comes before other
    /// - `isAfter(_:by:)`: Check if self comes after other
    /// - `isEquivalent(to:by:)`: Check if self is equivalent to other
    ///
    /// For types that also conform to `Comparison.Protocol` (an **intrinsic**
    /// total order), convenience methods without the `by:` parameter use that
    /// intrinsic order as natural ascending order.
    public var order: Property<Order, Self>.Inout {
        mutating _read {
            yield Property<Order, Self>.Inout(&self)
        }
    }
}
