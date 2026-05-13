# Order and Property.Inout

@Metadata {
    @TitleHeading("Order Primitives")
}

How the `.order` fluent property attaches ordering predicates to any value via `Property<Order, Base>.Inout`.

## Overview

`Order` is both the namespace under which `Order.Comparator`, `Order.Direction`, `Order.Projection`, and `Order.Orderable` live AND the phantom tag carried into `Property<Order, Base>.Inout`. The same enum plays both roles. There is no `Order.Tag` sub-name: the namespace itself is the tag.

The fluent `.order.<verb>` chain comes from a `Property<Order, Base>.Inout` value yielded by the `.order` accessor:

```swift
// On Order.Orderable types
extension Order.Orderable where Self: ~Copyable {
    public var order: Property<Order, Self>.Inout { ... }
}

// On Swift.Comparable types (@_disfavoredOverload — Orderable wins where both apply)
extension Swift.Comparable where Self: Copyable {
    public var order: Property<Order, Self>.Inout { ... }
}
```

The ordering predicates — `isBefore(_:by:)`, `isAfter(_:by:)`, `isEquivalent(to:by:)` — are declared as extensions on `Property.Inout where Tag == Order, Base: ~Copyable`. Convenience overloads dropping the `by:` parameter live on `Tag == Order, Base: Comparison.\`Protocol\` & ~Copyable` and `Tag == Order, Base: Swift.Comparable & ~Copyable` (the latter `@_disfavoredOverload`).

```swift
var alice = Person(name: "Alice", age: 30)
let bob   = Person(name: "Bob",   age: 25)

let byAge = Order.Comparator<Person>.by { $0.age }

alice.order.isBefore(bob, by: byAge)         // false
alice.order.isAfter(bob, by: byAge)          // true
alice.order.isEquivalent(to: alice, by: byAge)  // true

// Comparison.Protocol convenience — `by:` parameter dropped
var x: Int = 5
x.order.isBefore(10)                          // true
```

## Why a Property.Inout instead of methods on Self?

The Property surface lets the predicate code declare its constraints against `Property<Order, Base>.Inout` (with `Tag == Order` and a refinement on `Base`) rather than on the consumer type directly. Three benefits:

**No conformance required for stdlib types.** `Int`, `UInt8`, `String`, `Double`, `Float`, `Character` get the `.order.<verb>` chain via the `Swift.Comparable where Self: Copyable` extension without each having to opt-in to `Order.Orderable`. Retroactive conformances for these types stay declarative and short (see ``Order_Primitives/Order/Orderable``).

**Predicate methods aren't named on the consumer type.** `Int.isBefore(_:)` would collide with consumer-defined predicates and pollute the standard library namespace. `Int(...)` callers don't see `isBefore`; only `Int.order` does.

**`~Copyable` carry-forward.** The `Property<Order, Base>.Inout` value yielded by `.order` holds a borrow of `&self`, so `~Copyable` `Base`s flow through without copying. The predicate methods then declare `borrowing Base` parameters, preserving the chain.

## `is`-prefix Boolean predicates

`alice.order.isBefore(bob, by: byAge)` reads as a yes/no question — a Boolean-question predicate in the stdlib idiom (`Int.isMultiple(of:)`, `Sequence.isEmpty`, `Float.isFinite`). The `.order` namespace already supplies the *what's-this-about* context; the predicate name only needs to express the question.

`is`-prefix Boolean predicates are not the `verbObject`-form compound name pattern (`openWrite`, `walkFiles`); that pattern is reserved for the case where one identifier carries both an action and an object. The `.order.<verb>` chain partitions naturally: `.order` names the operation domain, `is<X>` names the predicate within that domain.

## Conforming to `Order.Orderable`

Types opt in to `Order.Orderable` to expose `.order` on values that are NOT `Swift.Comparable`:

```swift
struct Person: Order.Orderable {
    let name: String
    let age: Int
}

// .order is available because Person: Order.Orderable
var alice = Person(name: "Alice", age: 30)
alice.order.isBefore(bob, by: byAge)
```

For `~Copyable` types, conformance is declared with a `~Copyable` element constraint:

```swift
struct Token: ~Copyable, Order.Orderable, Comparison.`Protocol` {
    let id: Int
    static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool { lhs.id < rhs.id }
    static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool { lhs.id == rhs.id }
}
```

A `~Copyable, Comparison.\`Protocol\``-conformant value gets the convenience overloads automatically:

```swift
var t = Token(id: 5)
let u = Token(id: 10)
t.order.isBefore(u)        // true — natural ascending, no `by:` needed
```

## See also

- <doc:Comparator> — the value passed via `by:`.
- ``Order_Primitives/Order/Orderable`` — the opt-in protocol.
- <doc:Architecture> — the place of Order within the cohort.
