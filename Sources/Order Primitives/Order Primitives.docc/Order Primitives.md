# ``Order_Primitives``

@Metadata {
    @DisplayName("Order Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

A reified-comparator primitive — `Order.Comparator<T>`, a `Sendable` value capturing *how* to compare two `T`s, with chaining (`.then`), projection (`.by`), reversal (`.reversed`), and a partial-order companion `Order.Comparator.Partial` for cases like NaN where two values may be incomparable.

## Overview

`Order_Primitives` is the *operation* side of the comparison trichotomy. ``Comparison_Primitives/Comparison`` (re-exported) names the **result** of a comparison (`.less` / `.equal` / `.greater`); ``Order_Primitives/Order/Comparator`` names a **rule** for producing that result for two `T`s.

The `Order` namespace enum (``Order_Primitives/Order``) plays a dual role: it is the surface for `Order.Direction`, `Order.Comparator`, `Order.Projection`, `Order.Orderable`, AND it is the phantom tag carried into `Property<Order, Base>.Inout` so the `.order.<verb>` fluent chain attaches to any conforming or `Swift.Comparable` `Base`.

`Order` is the root of an independent path within **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — **order**, index, sequence, collection, input, cyclic, vector. Story 1 (cardinal, ordinal, affine) shipped 2026-05-12. The two direct dependencies — ``Comparison_Primitives`` and ``Property_Primitives`` — are honest: removing either breaks the result-vs-rule split or the fluent-property attachment.

## Topics

### Essentials

- <doc:Comparator>
- <doc:Projection>
- <doc:Direction>
- <doc:Order-and-Property>
- <doc:Architecture>

### Namespace

- ``Order_Primitives/Order``

### Comparator surface

- ``Order_Primitives/Order/Comparator``
- ``Order_Primitives/Order/Comparator/Partial``

### Projection and Direction

- ``Order_Primitives/Order/Projection``
- ``Order_Primitives/Order/Direction``

### Fluent surface

- ``Order_Primitives/Order/Orderable``
