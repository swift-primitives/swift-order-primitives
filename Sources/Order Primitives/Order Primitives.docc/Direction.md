# ``Order_Primitives/Order/Direction``

@Metadata {
    @DisplayName("Direction")
    @TitleHeading("Order Primitives")
}

Ascending or descending — a two-case enum that parameterizes sort direction in APIs that take it explicitly.

## Overview

`Order.Direction` is `.ascending` (smaller values first) or `.descending` (larger values first). It is `Sendable`, `Hashable`, and `CaseIterable`.

```swift
func sort<Value: Comparison.`Protocol`>(
    by selector: (Element) -> Value,
    direction: Order.Direction = .ascending
)
```

Most ordering code reaches for `Comparator` (a complete rule, including direction) or `Projection` (an extractor with a baked-in direction). `Direction` is the small, focused enum that exists when *only* the direction is the parameter — typically in sort-routine call sites that accept the field selector separately.

## Involution

`.reversed` swaps the two cases. The operation is an involution: `direction.reversed.reversed == direction` for every value.

```swift
Order.Direction.ascending.reversed   // .descending
Order.Direction.descending.reversed  // .ascending
Order.Direction.ascending.reversed.reversed == .ascending   // true
```

The involution is part of the contract: a function that takes a `Direction` parameter and internally flips it twice (for, say, a recursive descent) gets back exactly the caller's input.

## Role inside Comparator and Projection

`Order.Comparator` does not store a `Direction`; it stores the comparison closure directly and ``Order_Primitives/Order/Comparator/reversed`` produces a new comparator whose closure flips the result. `Order.Projection` does store a `Direction` so the projection's identity captures the chosen direction without collapsing to a comparator until requested.

If a caller asks "ascending or descending?", it depends which layer the question is at:

- The **comparator** layer answers with the closure semantics. `comparator(.ascending: a, b) == comparator(.descending: a, b).reversed`.
- The **projection** layer answers via the stored field. `projection.direction == .descending` reads the field directly without instantiating the comparator.

## See also

- <doc:Comparator> — the type that consumes `Direction` semantics but doesn't store the field.
- <doc:Projection> — the type that stores `Direction` as a field.
