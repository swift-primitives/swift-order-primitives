# ``Order_Primitives/Order/Comparator``

@Metadata {
    @DisplayName("Comparator")
    @TitleHeading("Order Primitives")
}

A reified, `Sendable`, closure-stored value that determines the relative order of two `T`s.

## Overview

`Order.Comparator<T: ~Copyable>` carries a `@Sendable (borrowing T, borrowing T) -> Comparison` closure. Comparators are first-class values: store them, pass them, compose them, reverse them. The closure-stored shape is what enables `.then(_:)` chaining, `.by(_:)` projection, and `.reversed` to compose without per-method overrides.

```swift
let byAge = Order.Comparator<Person>.by { $0.age }
let byName = Order.Comparator<Person>.by { $0.name }

let comparator = byAge.then(byName)         // age primary, name tie-break
let reversed   = byAge.reversed             // oldest first
let result     = comparator(alice, bob)     // .less / .equal / .greater
```

The `T: ~Copyable` upper bound is intentional: comparators apply to non-copyable values without forcing the value into the closure as a copy. The closure parameters are `borrowing T` so the constraint propagates the whole way down — `.then(_:)`, `.by(_:)`, `.reversed`, `callAsFunction` all preserve borrowing semantics.

## Constructing comparators

Three constructors cover the common cases. Pick the one that matches what you have at the call site:

- ``Order_Primitives/Order/Comparator/init(_:)`` — a `(borrowing T, borrowing T) -> Comparison` closure. Use when the comparison rule is custom enough that no factory applies.
- ``Order_Primitives/Order/Comparator/init()`` — available when `T: Comparison.\`Protocol\` & ~Copyable`. The canonical "natural ordering" comparator.
- ``Order_Primitives/Order/Comparator/by(_:)-2fb1k`` — key-extractor; available for both `Comparison.\`Protocol\`` keys (preferred) and `Swift.Comparable` keys (`@_disfavoredOverload`).

For `Swift.Comparable` types, `.ascending` and `.descending` are the static-property entries. The `.ascending` accessor inlines the `Comparison(comparing: lhs, to: rhs)` bridge directly; `.descending` is `ascending.reversed`. Earlier revisions exposed an `init(swift: Void)` initializer that wrapped the same bridge; it was removed for mechanism-leaking the bridging path through the API.

## Composing comparators

`Order.Comparator` forms a monoid under `.then(_:)` with the "always-equal" comparator as identity:

```swift
// Multi-field sort: name ascending, then age descending
let comparator = Order.Comparator<Person>
    .by { $0.name }
    .then(Order.Comparator<Person>.by { $0.age }.reversed)
```

The `.then(_:)` operator is short-circuit on a `.less` / `.greater` result from the primary comparator — the secondary is only consulted on `.equal`. A lazy variant — ``Order_Primitives/Order/Comparator/then(with:)`` — defers the secondary's evaluation behind a closure so a tie-break that is expensive to construct is only paid when ties happen.

## Sendable and metatype captures

`Order.Comparator` is `Sendable` unconditionally; the stored `compare` closure is `@Sendable` and the rest of the struct is value-typed. The static factories that bridge `Swift.Comparable` keys (`init()` over `Comparison.\`Protocol\``, `.by(_:)` for both `Comparison.\`Protocol\`` and `Swift.Comparable` keys, the `Swift.Comparable` `.ascending` path) capture a `T.Type` or `Value.Type` in their `@Sendable` closure. The compiler emits a `#SendableMetatypes` diagnostic at these sites; metatypes (`T.Type`) are pointers into read-only type metadata in the binary and are inherently thread-safe, but the type system does not yet distinguish "the metatype of `T`" (always safe) from "a value of type `T`" (may not be safe). Each site is annotated `nonisolated(unsafe) let _: T.Type = T.self` to document the intent. The warnings do not propagate into consumer builds.

## `@inlinable` and performance

Every method on `Order.Comparator` carries `@inlinable`. The intent is for the optimizer to dissolve the closure indirection at sites where the comparator is a compile-time-known `.ascending` / `.descending` or a closure literal, reducing the cost to the underlying `Comparison.\`Protocol\``'s `<`.

For tight inner loops, reach for `Comparison.\`Protocol\`` directly rather than wrapping the natural ordering in a `Comparator`.

## See also

- <doc:Projection> — key-based ordering specifications, the longer-form `Comparator.by(_:)` factorization.
- <doc:Direction> — ascending vs descending and the involution.
- <doc:Order-and-Property> — the `.order` fluent property and how a comparator drives `isBefore(_:by:)` / `isAfter(_:by:)` / `isEquivalent(to:by:)`.
- ``Order_Primitives/Order/Comparator/Partial`` — the refinement for partial orders.
