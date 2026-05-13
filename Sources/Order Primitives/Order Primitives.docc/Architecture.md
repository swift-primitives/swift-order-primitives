# Architecture

@Metadata {
    @TitleHeading("Order Primitives")
}

The package's product layout and the design rationale for its surface.

## Overview

`Order_Primitives` depends only on `swift-comparison-primitives` and `swift-property-primitives`. The package is self-contained on the trichotomy frame: it does not depend on any other typed-indexing primitive, and downstream packages compose it indirectly through their use of the Comparison / Order / Property split.

## Product layout

Two library products. The package is small (16 source files, ~1050 LOC) and the trichotomy frame does not require a separate Standard-Library-Integration target — the `Swift.Comparable` bridging lives in the umbrella next to the `Comparison.\`Protocol\`` core.

| Product | Target | Purpose |
|---------|--------|---------|
| `Order Primitives` | `Sources/Order Primitives/` | The `Order` namespace, all member types, the `.order` fluent surface, and the `Swift.Comparable` bridging. Re-exports `Comparison_Primitives` so `import Order_Primitives` brings the result types into scope too. |
| `Order Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella plus `Property_Primitives_Test_Support` for downstream test consumers. |

## The comparison trichotomy

Three packages divide the labor of ordering values; each answers a distinct question:

| Package | Question answered | Carries |
|---|---|---|
| `swift-comparison-primitives` | What is the *result* of comparing two values? | `Comparison` (`.less` / `.equal` / `.greater`) and `Comparison.\`Protocol\`` for types with a single natural ordering |
| **`swift-order-primitives`** (this package) | What is the *rule* that produces that result for a given pair? | `Order.Comparator<T>` with chaining / projection / reversal; `Order.Direction`; `Order.Projection<Root, Value>`; the `.order` fluent property |
| `swift-property-primitives` | How does a fluent `.<verb>` chain attach to a value without forcing it into a protocol? | `Property<Tag, Base>` with `.Inout` for in-place predicates; `Order` is the phantom tag carried into `Property<Order, Self>.Inout` |

The trichotomy is the load-bearing design decision. Most code only needs one of the two: a sort routine takes a comparator, a tight inner loop takes a `Comparison.\`Protocol\``-conformant type. The split keeps imports honest about which one the call site actually needs.

## Dependency closure

Two direct dependencies. Each is honest — removing either breaks a load-bearing piece of the surface:

| Dependency | Why |
|------------|-----|
| `swift-comparison-primitives` | Provides `Comparison` (returned by every comparator) and `Comparison.\`Protocol\`` (the natural-ordering refinement). Removing it leaves `Comparator` returning nothing meaningful. |
| `swift-property-primitives` | Provides `Property<Tag, Base>` and `.Inout` — the machinery the `.order` accessor yields. Removing it would force the predicate methods (`isBefore(_:by:)` etc.) directly onto each consumer type, fragmenting the surface and forcing per-type conformances even for stdlib types like `Int`. |

The umbrella re-exports `swift-comparison-primitives` (`@_exported public import Comparison_Primitives` in `exports.swift`). `swift-property-primitives` is imported `public import Property_Primitives` at the file scope where `Property.Inout` extensions are declared; consumers reach for it directly when they want to name `Property<Order, T>.Inout` in their own signatures.

## Foundation-free, no platform conditionals

No `import Foundation`, no `#if os(…)` guards, no async / actor surface in `Sources/`. The only concurrency surface is the `@Sendable` constraint on the closures stored in `Order.Comparator` and `Order.Projection`; these are value-typed wrappers, not actors.

Swift Embedded is supported — the Wasm SDK build and Swift 6.4-dev nightly Embedded matrix both pass in CI.
