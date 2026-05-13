# Order Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A reified-comparator primitive — `Order.Comparator<T>`, a `Sendable` value that captures *how* to compare two `T`s, with chaining (`.then`), projection (`.by`), reversal (`.reversed`), and a partial-order companion `Order.Comparator.Partial` for cases like NaN where two values may be incomparable.

`Order` is the *operation* side of the comparison trichotomy: `Comparison` (from [`swift-comparison-primitives`](https://github.com/swift-primitives/swift-comparison-primitives)) names the **result** of a comparison (`.less` / `.equal` / `.greater`); `Order.Comparator<T>` names a **rule** for producing that result for two `T`s. Sorting and predicate code reaches for `Order` when the rule itself is the value being passed around; reaches for `Comparison.\`Protocol\`` when a single type's natural ordering is enough.

---

## Quick Start

```swift
import Order_Primitives

// A reified comparator — a value capturing "how to compare"
let byAge = Order.Comparator<Person>.by { $0.age }

// Chain comparators for tie-break sequencing
let comparator = byAge.then(Order.Comparator<Person>.by { $0.name })

// Reverse for descending order
let oldestFirst = byAge.reversed

// Use directly — `Comparator` is callable
let alice = Person(name: "Alice", age: 30)
let bob   = Person(name: "Bob",   age: 25)
byAge(alice, bob)   // .greater  (30 > 25)

// Or fluently, via the `.order` property on any Order.Orderable type
var carol = Person(name: "Carol", age: 30)
carol.order.isBefore(bob, by: byAge)         // false (30 > 25)
carol.order.isEquivalent(to: alice, by: byAge)  // true

// `Comparison.Protocol` types skip the explicit comparator
var x: Int = 5
x.order.isBefore(10)                          // true
```

`Person` here is any `struct` that opts into `Order.Orderable` (or any type that already conforms to `Swift.Comparable` — stdlib integer types, `String`, `Double`, `Float`, `Character` carry the conformance out of the box). The `.order.<verb>` chain works the same way in both cases.

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-order-primitives.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Order Primitives", package: "swift-order-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## The comparison trichotomy

Three packages divide the labor of ordering values:

| Package | Question answered | Carries |
|---|---|---|
| [`swift-comparison-primitives`](https://github.com/swift-primitives/swift-comparison-primitives) | What is the *result* of comparing two values? | `Comparison` (`.less` / `.equal` / `.greater`) and `Comparison.\`Protocol\`` for types with a single natural ordering |
| **`swift-order-primitives`** (this package) | What is the *rule* that produces that result for a given pair? | `Order.Comparator<T>` reified comparators with chaining / projection / reversal; `Order.Direction`; `Order.Projection<Root, Value>`; the `.order` fluent property |
| [`swift-property-primitives`](https://github.com/swift-primitives/swift-property-primitives) | How does a fluent `.<verb>` chain attach to a value without forcing it into a protocol? | `Property<Tag, Base>` with `.Inout` for in-place predicates; `Order` is the phantom tag carried into `Property<Order, Self>.Inout` |

`Comparison` is the answer at the *result* layer; `Order.Comparator` is the answer at the *rule* layer. The boundary is deliberate: most code only needs one of the two — a sort routine takes a comparator, a tight inner loop takes a `Comparison.\`Protocol\``-conformant type — and the split keeps the imports honest about which one the call site actually needs.

---

## Architecture

Two library products covering the namespace and a Test Support target.

| Product | Target | Purpose |
|---------|--------|---------|
| `Order Primitives` | `Sources/Order Primitives/` | The `Order` namespace, all its types, and the `.order` fluent surface. Re-exports `Comparison_Primitives` so a single `import Order_Primitives` brings the result types into scope too. |
| `Order Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella plus `Property_Primitives_Test_Support` for downstream test consumers. |

Order's surface lives under the `Order` namespace enum:

- `Order.Direction` — ascending vs descending; `.reversed` is an involution
- `Order.Comparator<T>` — the reified comparator, parameterized over `T: ~Copyable`; closure-stored `@Sendable` value
- `Order.Comparator.Partial` — refinement, not sibling, of `Comparator` for partial orders (returns `Comparison?` rather than `Comparison`)
- `Order.Projection<Root, Value>` — key-extracting projection that converts to a `Comparator` via `.comparator`
- `Order.Orderable` — opt-in protocol providing the `.order` fluent property
- `.order` accessor — yields `Property<Order, Self>.Inout`, on which `isBefore(_:by:)`, `isAfter(_:by:)`, `isEquivalent(to:by:)` are defined (with `Comparison.\`Protocol\`` convenience overloads dropping the `by:`)

The `Order` enum is the namespace AND the phantom tag for `Property<Order, Base>.Inout`. The same enum plays both roles: types live under it, and the type itself anchors which `Property.Inout` extensions get the `.order.<verb>` predicates.

Two upstream dependencies:

- [`swift-comparison-primitives`](https://github.com/swift-primitives/swift-comparison-primitives) — provides `Comparison` and `Comparison.\`Protocol\``
- [`swift-property-primitives`](https://github.com/swift-primitives/swift-property-primitives) — provides `Property<Tag, Base>` and `.Inout`

Foundation-free. No platform conditionals. No concurrency surface in sources beyond the `@Sendable` constraint on stored closures.

---

## `~Copyable` carry-forward

`Order.Comparator<T: ~Copyable>` is the default upper bound; comparators apply to non-copyable values without forcing the value into the closure as a copy. The closure parameters are `borrowing T`, propagating the constraint through the rule, the projection, and the fluent `.order.<verb>(_:by:)` chain.

This is what enables `Property<Order, Base>.Inout` to attach the predicate methods to a `~Copyable` `Base` without copying it. A `Token: ~Copyable` value can ask `myToken.order.isBefore(otherToken, by: byID)` and the comparator runs against borrowed references the whole way down.

The `@Sendable` constraint on the closure does not propagate a `Copyable` upper bound onto `T` itself: `@Sendable` constrains the *closure* (its captures), not the *closure parameters*. A `~Copyable` `T` flows through `borrowing T` parameters into a `@Sendable` closure body the same way it would through any other `borrowing` site.

---

## Performance posture

`Order.Comparator<T>` is a closure-stored struct; every method on it carries `@inlinable`. The intent is for the optimizer to dissolve the indirection at sites where the comparator is a compile-time-known `.ascending` / `.descending` or a closure literal — the cost reduces to the underlying `Comparison.\`Protocol\`` `<` call. If a hot inner loop requires direct `<` access, reach for `Comparison.\`Protocol\``'s natural ordering rather than wrapping it in a `Comparator` value.

A few `Order.Comparator` extensions emit `#SendableMetatypes` warnings on `swift build` (the metatype `T.Type` is inherently thread-safe but the diagnostic is conservative). They do not propagate into consumer builds via the umbrella product.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Linux | Full support |
| Windows | Full support |
| Swift Embedded | Supported (Wasm SDK + Swift 6.4-dev nightly CI matrix passes) |

---

## Stability

Pre-1.0. The public API of `Order` and its members may change while the package remains on `branch: "main"`; consumers should expect breaking changes to surface in commit messages until the first tag. Once tagged, the package follows institute SemVer: post-1.0 breaking changes ship behind a major bump.

The phantom-tag identity of the `Order` namespace enum is part of the public surface — code reaching for `Property<Order, …>.Inout` directly is binding to that identity. Renaming the namespace (or splitting types out of it) is a breaking change after tag.

---

## Related Packages

Direct dependencies:

- [swift-comparison-primitives](https://github.com/swift-primitives/swift-comparison-primitives) — `Comparison` and `Comparison.\`Protocol\``
- [swift-property-primitives](https://github.com/swift-primitives/swift-property-primitives) — `Property<Tag, Base>` and `Property.Inout`

---

## Community

<!-- BEGIN: discussion -->
Discuss this package: [swift-institute/discussions/27](https://github.com/orgs/swift-institute/discussions/27)
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
