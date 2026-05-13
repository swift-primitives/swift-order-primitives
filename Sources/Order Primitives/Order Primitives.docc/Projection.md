# ``Order_Primitives/Order/Projection``

@Metadata {
    @DisplayName("Projection")
    @TitleHeading("Order Primitives")
}

A key-extracting projection that converts to an `Order.Comparator` with a chosen direction.

## Overview

`Order.Projection<Root, Value>` carries two pieces of data: a `@Sendable (borrowing Root) -> Value` extractor and an `Order.Direction`. The combination is enough to derive a comparator on demand via ``Order_Primitives/Order/Projection/comparator``.

```swift
let byAgeDescending = Order.Projection<Person, Int>(
    { $0.age },
    direction: .descending
)

let comparator = byAgeDescending.comparator   // Order.Comparator<Person>
```

`Root: ~Copyable, Value: Comparison.\`Protocol\` & ~Copyable` is the default upper bound: a projection from a non-copyable root over a non-copyable comparable key is a first-class shape.

## Projection vs `Comparator.by(_:)`

`Order.Comparator.by(_:)` is the shortcut form — same extractor, ascending direction baked in:

```swift
let byAge = Order.Comparator<Person>.by { $0.age }
// equivalent to: Order.Projection<Person, Int>({ $0.age }).comparator
```

`Projection` exists for cases where the projection itself is the value being passed around. A higher-level API that takes a `Projection<Root, Value>` parameter can decide later whether to reverse it, chain it, or hand it to a sort routine. The factorization keeps the projection identity available; `Comparator.by(_:)` collapses to the comparator immediately. Use whichever names the call site's concept best:

- The call site already holds a `Comparator` or wants one immediately — use `Comparator.by(_:)`.
- The call site is producing a value that another layer will configure or compose — use `Projection`.

## `.reversed` and `.comparator`

`Projection` carries a `.reversed` accessor that flips the `direction` field (involutive, like ``Order_Primitives/Order/Direction``'s own `.reversed`). The `.comparator` accessor builds the `Comparator<Root>` lazily: it constructs the base `Comparator.by(extract)` and reverses it iff `direction == .descending`.

```swift
let byAge = Order.Projection<Person, Int> { $0.age }
let oldestFirst = byAge.reversed.comparator    // Order.Comparator<Person>, descending
```

The two-step factorization (projection → comparator) keeps the direction explicit at the projection layer and the comparator surface clean of direction parameters.

## Sendable and metatype captures

The `extract` closure stored in `Order.Projection` is `@Sendable`. The same `#SendableMetatypes` consideration as ``Order_Primitives/Order/Comparator`` applies for the `Value.Type` capture in `.by(_:)` factories; see the Comparator article's discussion.

## See also

- <doc:Comparator> — the `Order.Comparator` value the projection converts to.
- <doc:Direction> — the `Direction` field's role and involution.
