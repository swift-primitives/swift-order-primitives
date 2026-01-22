// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

/// Namespace for ordering-related types.
///
/// The `Ordering` namespace contains types that define *how* values should
/// be compared, as opposed to `Comparison` which represents the *result*
/// of comparing values.
///
/// ## Types
///
/// - ``Ordering/Direction``: Ascending or descending order
/// - ``Ordering/Comparator``: A reified comparator function
/// - ``Ordering/Projection``: Key-based ordering specification
/// - ``Ordering/PartialComparator``: Comparator for partial orders
///
/// ## Fluent APIs
///
/// - ``Ordering/Order``: Tag type for `.order` property
/// - ``Ordering/Orderable``: Protocol providing `.order` property
public enum Ordering: Sendable {}
