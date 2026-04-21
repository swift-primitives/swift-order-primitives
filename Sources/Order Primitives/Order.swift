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
/// The `Order` namespace contains types that define *how* values should
/// be compared, as opposed to `Comparison` which represents the *result*
/// of comparing values.
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
/// - ``Order/Order``: Tag type for `.order` property
/// - ``Order/Orderable``: Protocol providing `.order` property
public enum Order: Sendable {}
