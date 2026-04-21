---
name: ordering-primitives
description: |
  Order and comparison primitives for total and partial orders.
  ALWAYS apply when working with comparison semantics.

layer: implementation

requires:
  - primitives
  - naming

applies_to:
  - swift
  - swift-primitives
  - swift-order-primitives
---

# Order Primitives

Total and partial ordering primitives.

---

## Core Design Decisions

### [ORD-001] Order Type Hierarchy

| Type | Semantics |
|------|-----------|
| `Order.Total` | Complete ordering (every pair comparable) |
| `Order.Partial` | May have incomparable pairs |

---

## Cross-References

Full analysis: `Research/Order Primitives Design.md`
