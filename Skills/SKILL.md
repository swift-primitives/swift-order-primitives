---
name: ordering-primitives
description: |
  Ordering and comparison primitives for total and partial orders.
  ALWAYS apply when working with comparison semantics.

layer: implementation

requires:
  - primitives
  - naming

applies_to:
  - swift
  - swift-primitives
  - swift-ordering-primitives
---

# Ordering Primitives

Total and partial ordering primitives.

---

## Core Design Decisions

### [ORD-001] Order Type Hierarchy

| Type | Semantics |
|------|-----------|
| `Ordering.Total` | Complete ordering (every pair comparable) |
| `Ordering.Partial` | May have incomparable pairs |

---

## Cross-References

Full analysis: `Research/Ordering Primitives Design.md`
