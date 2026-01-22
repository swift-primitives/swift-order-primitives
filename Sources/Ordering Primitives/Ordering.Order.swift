// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

extension Ordering {
    /// Tag type for `.order` property extensions.
    ///
    /// `Ordering.Order` is a phantom type used with `Property.View` to provide
    /// fluent APIs for checking relative ordering of values using comparators.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Person: Orderable {
    ///     let name: String
    ///     let age: Int
    /// }
    ///
    /// let byAge = Ordering.Comparator<Person> { lhs, rhs in
    ///     Comparison(comparing: lhs.age, to: rhs.age)
    /// }
    ///
    /// var alice = Person(name: "Alice", age: 30)
    /// let bob = Person(name: "Bob", age: 25)
    ///
    /// alice.order.isBefore(bob, by: byAge)  // false (30 > 25)
    /// alice.order.isAfter(bob, by: byAge)   // true
    /// ```
    public enum Order {}
}
