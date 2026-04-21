// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Property_Primitives

// MARK: - Property.View Extension for Swift.Comparable

/// Property.View extensions for ordering operations on `Swift.Comparable` types.
///
/// This extension provides convenience methods that use natural ascending order
/// for standard library types that conform to `Swift.Comparable`.
///
/// Note: Methods are marked `@_disfavoredOverload` so that types conforming to
/// both `Comparison.Protocol` and `Swift.Comparable` (like `Int`) use the
/// `Comparison.Protocol` extension.

// SE-0499: Swift.Comparable no longer implies Copyable in Swift 6.4.
// Without ~Copyable, the extension gains implicit `where Base: Copyable` on 6.4,
// making it unreachable for ~Copyable types.
#if compiler(>=6.4)
extension Property.View where Tag == Order.Order, Base: Swift.Comparable & ~Copyable {

    @_disfavoredOverload
    @inlinable
    public func isBefore(_ other: borrowing Base) -> Bool {
        isBefore(other, by: .ascending)
    }

    @_disfavoredOverload
    @inlinable
    public func isAfter(_ other: borrowing Base) -> Bool {
        isAfter(other, by: .ascending)
    }

    @_disfavoredOverload
    @inlinable
    public func isEquivalent(to other: borrowing Base) -> Bool {
        isEquivalent(to: other, by: .ascending)
    }
}
#else
extension Property.View where Tag == Order.Order, Base: Swift.Comparable {

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
    /// Returns a `Property.View` that provides ordering methods like
    /// `.isBefore(_:)`, `.isAfter(_:)`, `.isEquivalent(to:)`.
    @_disfavoredOverload
    public var order: Property<Order.Order, Self>.View {
        mutating _read {
            yield unsafe Property<Order.Order, Self>.View(&self)
        }
    }
}
