// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

public import Pair_Primitives

extension Order {
    /// Monotonic behavior: increasing, decreasing, or constant.
    ///
    /// Describes how a function's output changes relative to its input. Monotone
    /// functions preserve or reverse order. Use when classifying functions or
    /// sequences by their ordering properties. A three-valued sibling of
    /// `Order.Direction` (which has only ascending/descending), adding the
    /// `.constant` case for order-preserving-and-reversing behavior.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let behavior: Order.Monotonicity = .increasing
    /// print(behavior.reversed)         // decreasing
    /// print(behavior.isNonDecreasing)  // true
    /// ```
    public enum Monotonicity: Sendable, Hashable, CaseIterable {
        /// Output increases as input increases.
        case increasing

        /// Output decreases as input increases.
        case decreasing

        /// Output remains the same regardless of input.
        case constant
    }
}

// MARK: - Reversal

extension Order.Monotonicity {
    /// Reversed monotonicity (swaps increasing↔decreasing, preserves constant).
    @inlinable
    public static func reversed(_ monotonicity: Order.Monotonicity) -> Order.Monotonicity {
        switch monotonicity {
        case .increasing: return .decreasing
        case .decreasing: return .increasing
        case .constant: return .constant
        }
    }

    /// Reversed monotonicity (swaps increasing↔decreasing, preserves constant).
    @inlinable
    public var reversed: Order.Monotonicity {
        Order.Monotonicity.reversed(self)
    }

    /// Returns the reversed monotonicity.
    @inlinable
    public static prefix func ! (value: Order.Monotonicity) -> Order.Monotonicity {
        value.reversed
    }
}

// MARK: - Composition

extension Order.Monotonicity {
    /// Monotonicity of composing two monotonic functions (f ∘ g).
    @inlinable
    public static func composing(_ lhs: Order.Monotonicity, _ rhs: Order.Monotonicity) -> Order.Monotonicity {
        switch (lhs, rhs) {
        case (.constant, _), (_, .constant): return .constant
        case (.increasing, .increasing), (.decreasing, .decreasing): return .increasing
        case (.increasing, .decreasing), (.decreasing, .increasing): return .decreasing
        }
    }

    /// Monotonicity of composing two monotonic functions (f ∘ g).
    @inlinable
    public func composing(_ other: Order.Monotonicity) -> Order.Monotonicity {
        Order.Monotonicity.composing(self, other)
    }
}

// MARK: - Properties

extension Order.Monotonicity {
    /// Whether the monotonicity is strictly `.increasing`.
    @inlinable
    public var isIncreasing: Bool { self == .increasing }

    /// Whether the monotonicity is strictly `.decreasing`.
    @inlinable
    public var isDecreasing: Bool { self == .decreasing }

    /// Whether the monotonicity is `.constant`.
    @inlinable
    public var isConstant: Bool { self == .constant }

    /// Whether the monotonicity is non-decreasing (`.increasing` or `.constant`).
    @inlinable
    public var isNonDecreasing: Bool { self != .decreasing }

    /// Whether the monotonicity is non-increasing (`.decreasing` or `.constant`).
    @inlinable
    public var isNonIncreasing: Bool { self != .increasing }
}

// MARK: - Tagged Value

extension Order.Monotonicity {
    /// A value paired with its monotonicity.
    public typealias Value<Payload> = Pair<Order.Monotonicity, Payload>
}

// MARK: - Codable

#if !hasFeature(Embedded)
    extension Order.Monotonicity: Codable {}
#endif
