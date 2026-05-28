// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

extension Order {
    /// Direction of ordering: ascending or descending.
    ///
    /// Use `Direction` to parameterize sort direction in APIs:
    ///
    /// ```swift
    /// func sort<Value: Comparison.`Protocol`>(
    ///     by selector: (Element) -> Value,
    ///     direction: Order.Direction = .ascending
    /// )
    /// ```
    public enum Direction: Sendable, Hashable, CaseIterable {
        /// Smaller values come first.
        case ascending

        /// Larger values come first.
        case descending

        /// Returns the opposite direction.
        ///
        /// - `.ascending` becomes `.descending`
        /// - `.descending` becomes `.ascending`
        @inlinable
        public var reversed: Self {
            switch self {
            case .ascending: return .descending
            case .descending: return .ascending
            }
        }
    }
}
