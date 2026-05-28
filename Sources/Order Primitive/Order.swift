// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

/// Namespace and phantom-tag anchor for ordering-related types.
///
/// `Order` is both the namespace under which comparator and projection
/// types live and the phantom tag for the `.order` fluent property:
/// `Property<Order, Base>.Inout` is the value yielded by
/// `Order.Orderable`'s `.order` accessor, and the ordering predicates
/// (`isBefore(_:by:)`, `isAfter(_:by:)`, `isEquivalent(to:by:)`) are
/// declared as extensions of that `Property.Inout`.
///
/// `Order` describes *how* values should be compared, complementing
/// `Comparison`, which represents the *result* of a comparison.
///
/// ## Types
///
/// - ``Order/Direction``: Ascending or descending order
/// - ``Order/Comparator``: A reified comparator function
/// - ``Order/Projection``: Key-based ordering specification
/// - ``Order/Comparator/Partial``: Comparator for partial orders
///
/// ## Fluent APIs
///
/// - ``Order/Orderable``: Protocol providing the `.order` property
public enum Order: Sendable {}
