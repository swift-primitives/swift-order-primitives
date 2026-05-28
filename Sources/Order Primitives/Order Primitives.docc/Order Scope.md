# Order Primitives Scope

The identity surface of `swift-order-primitives` and what lies outside it.

## Identity

`swift-order-primitives` provides the **arrangement layer over the comparison
relation** (MSC 06-XX). Where `Comparison` (in `swift-comparison-primitives`)
names *how two values relate* — the three-way result and the intrinsic
total-order capability — `Order` names *how values are arranged* using that
relation: reified composable comparators, sort direction, key-based
projections, and extrinsic orderability. `Order` builds on `Comparison`; the
dependency direction `Order → Comparison` is correct (the relation is the
lower atom).

## Core targets

- **Order Primitive** — the root `enum Order {}` namespace and phantom tag
  (zero external dependencies per [MOD-017]).
- **Order Direction Primitives** — `Order.Direction` (ascending / descending,
  with `.reversed`). The canonical direction vocabulary for the cluster.
- **Order Comparator Primitives** — `Order.Comparator<T>` and its composition
  surface (chaining, reversal, projection, the `Comparison.Protocol` natural
  ordering) plus `Order.Comparator.Partial` for partial orders.
- **Order Orderable Primitives** — `Order.Orderable` (the extrinsic-order
  marker) and the `.order` fluent predicate surface on
  `Property<Order, Base>.Inout` (`isBefore` / `isAfter` / `isEquivalent`).
- **Order Projection Primitives** — `Order.Projection<Root, Value>`, a
  key-extraction-plus-direction specification convertible to a comparator.
- **Order Primitives Standard Library Integration** — the `Swift.Comparable`
  bridges (pre-SE-0499 / `#if swift(<6.4)`) that wire stdlib `Comparable`
  types into comparators, orderable conformances, and the `.order` accessor.

## Out of scope

- **The comparison relation itself** (the three-way result, `Comparison.Protocol`,
  `Compare`, `Clamp`): → `swift-comparison-primitives`. `Order` consumes it,
  does not own it.
- **Monotonicity** (3-valued direction-with-`constant`): currently parked in
  `swift-algebra-primitives` as `Algebra.Monotonicity`. It is a 06-XX
  order-theoretic classification and a sibling of `Order.Direction`; a future
  step relocates it to `Order.Monotonicity` (inbound, not yet landed). Do not
  add it speculatively here ahead of that move.
- **Interval bound/boundary/endpoint vocabulary**: → `swift-interval-primitives`.

## Evaluation rule

Sub-target additions are evaluated against this scope. If a proposed addition
is OUT of scope, it extracts to a sibling package, not into this one.
