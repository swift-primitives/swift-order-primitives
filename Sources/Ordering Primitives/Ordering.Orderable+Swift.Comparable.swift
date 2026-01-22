// Ordering.Orderable+Swift.Comparable.swift
// Bridge for Swift.Comparable types to use .order fluent API.

// MARK: - Ordering.Orderable Conformance for Integer Types

/// Conformance for `Int` to `Ordering.Orderable`.
///
/// Enables `Int` to use the `.order` fluent API for ordering comparisons.
extension Int: Ordering.Orderable {}

/// Conformance for `UInt` to `Ordering.Orderable`.
extension UInt: Ordering.Orderable {}

/// Conformance for `Int8` to `Ordering.Orderable`.
extension Int8: Ordering.Orderable {}

/// Conformance for `Int16` to `Ordering.Orderable`.
extension Int16: Ordering.Orderable {}

/// Conformance for `Int32` to `Ordering.Orderable`.
extension Int32: Ordering.Orderable {}

/// Conformance for `Int64` to `Ordering.Orderable`.
extension Int64: Ordering.Orderable {}

/// Conformance for `UInt8` to `Ordering.Orderable`.
extension UInt8: Ordering.Orderable {}

/// Conformance for `UInt16` to `Ordering.Orderable`.
extension UInt16: Ordering.Orderable {}

/// Conformance for `UInt32` to `Ordering.Orderable`.
extension UInt32: Ordering.Orderable {}

/// Conformance for `UInt64` to `Ordering.Orderable`.
extension UInt64: Ordering.Orderable {}

// MARK: - Ordering.Orderable Conformance for Other Standard Types

/// Conformance for `String` to `Ordering.Orderable`.
extension String: Ordering.Orderable {}

/// Conformance for `Double` to `Ordering.Orderable`.
extension Double: Ordering.Orderable {}

/// Conformance for `Float` to `Ordering.Orderable`.
extension Float: Ordering.Orderable {}

/// Conformance for `Character` to `Ordering.Orderable`.
extension Character: Ordering.Orderable {}
