// This source file is part of the Swift Institute open source project
//
// Copyright (c) 2025 Swift Institute and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0

// MARK: - Order.Orderable Conformance for Integer Types

/// Conformance for `Int` to `Order.Orderable`.
///
/// Enables `Int` to use the `.order` fluent API for ordering comparisons.
extension Int: Order.Orderable {}

/// Conformance for `UInt` to `Order.Orderable`.
extension UInt: Order.Orderable {}

/// Conformance for `Int8` to `Order.Orderable`.
extension Int8: Order.Orderable {}

/// Conformance for `Int16` to `Order.Orderable`.
extension Int16: Order.Orderable {}

/// Conformance for `Int32` to `Order.Orderable`.
extension Int32: Order.Orderable {}

/// Conformance for `Int64` to `Order.Orderable`.
extension Int64: Order.Orderable {}

/// Conformance for `UInt8` to `Order.Orderable`.
extension UInt8: Order.Orderable {}

/// Conformance for `UInt16` to `Order.Orderable`.
extension UInt16: Order.Orderable {}

/// Conformance for `UInt32` to `Order.Orderable`.
extension UInt32: Order.Orderable {}

/// Conformance for `UInt64` to `Order.Orderable`.
extension UInt64: Order.Orderable {}

// MARK: - Order.Orderable Conformance for Other Standard Types

/// Conformance for `String` to `Order.Orderable`.
extension String: Order.Orderable {}

/// Conformance for `Double` to `Order.Orderable`.
extension Double: Order.Orderable {}

/// Conformance for `Float` to `Order.Orderable`.
extension Float: Order.Orderable {}

/// Conformance for `Character` to `Order.Orderable`.
extension Character: Order.Orderable {}
