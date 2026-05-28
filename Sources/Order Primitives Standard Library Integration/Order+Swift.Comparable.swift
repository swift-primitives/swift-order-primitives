// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Property_Primitives
public import Order_Orderable_Primitives

// MARK: - Property.Inout Extension for Swift.Comparable (Swift <6.4 only)
//
// Pre-SE-0499 only. On Swift 6.4+ `Comparison.`Protocol`` is a typealias to
// `Swift.Comparable` (see swift-comparison-primitives' Comparison.Protocol.swift);
// the `Comparison.`Protocol` & ~Copyable` extension in Order+Property.Inout.swift
// automatically supplies these methods for Swift.Comparable types and a parallel
// declaration here would collide as a redeclaration.
//
// On Swift <6.4 the two protocols are disjoint, so this parallel surface is
// needed to give stdlib `Swift.Comparable` types (Int, UInt8, …) the
// `.order.is<X>(_:)` convenience without forcing each onto Comparison.Protocol.
// Methods carry `@_disfavoredOverload` to defer to Comparison.Protocol for
// types that conform to both.
#if swift(<6.4)
    extension Property.Inout where Tag == Order, Base: Swift.Comparable {

        /// Check if self comes before other using natural ascending order.
        ///
        /// ```swift
        /// var apple = "apple"
        /// apple.order.isBefore("banana")  // true
        /// ```
        ///
        /// - Parameter other: The value to compare against.
        /// - Returns: `true` if self comes before other in ascending order.
        @_disfavoredOverload
        @inlinable
        public func isBefore(_ other: Base) -> Bool {
            isBefore(other, by: .ascending)
        }

        /// Check if self comes after other using natural ascending order.
        ///
        /// ```swift
        /// var banana = "banana"
        /// banana.order.isAfter("apple")  // true
        /// ```
        ///
        /// - Parameter other: The value to compare against.
        /// - Returns: `true` if self comes after other in ascending order.
        @_disfavoredOverload
        @inlinable
        public func isAfter(_ other: Base) -> Bool {
            isAfter(other, by: .ascending)
        }

        /// Check if self is equivalent to other using natural ordering.
        ///
        /// ```swift
        /// var a = "hello"
        /// a.order.isEquivalent(to: "hello")  // true
        /// ```
        ///
        /// - Parameter other: The value to compare against.
        /// - Returns: `true` if self is equivalent to other under natural ordering.
        @_disfavoredOverload
        @inlinable
        public func isEquivalent(to other: Base) -> Bool {
            isEquivalent(to: other, by: .ascending)
        }
    }
#endif

// MARK: - .order Property for Swift.Comparable

/// Provides the `.order` property to all `Swift.Comparable` types.
///
/// This extension enables fluent ordering APIs for standard library types
/// like `String`, `Double`, `Float`, and `Character`.
///
/// ```swift
/// var name = "alice"
/// name.order.isBefore("bob")  // true
/// name.order.isAfter("bob")   // false
/// ```
///
/// Note: Marked `@_disfavoredOverload` so types that also conform to
/// `Order.Orderable` use the `Orderable` extension.
extension Swift.Comparable where Self: Copyable {
    /// Access fluent ordering APIs.
    ///
    /// Returns a `Property.Inout` that provides ordering methods like
    /// `.isBefore(_:)`, `.isAfter(_:)`, `.isEquivalent(to:)`.
    @_disfavoredOverload
    public var order: Property<Order, Self>.Inout {
        mutating _read {
            yield Property<Order, Self>.Inout(&self)
        }
    }
}
