# Audit: swift-ordering-primitives

## Accepted Compiler Warnings — 2026-03-25

### Scope

- **Target**: swift-ordering-primitives
- **Trigger**: Build log warning triage from `swift test` on swift-foundations
- **Files**: Ordering comparator extensions

### Context

During a full warning audit of the swift-foundations test build, three `#SendableMetatypes` warnings in the Ordering comparator extensions were identified as **not fixable** without either restricting the public API surface or introducing incorrect code. Accepted as a compiler limitation pending future Swift evolution.

### Findings

| # | Severity | Diagnostic | Location | Finding | Status |
|---|----------|------------|----------|---------|--------|
| 1 | — | `#SendableMetatypes` | `Ordering.Comparator+Swift.Comparable.swift:28,83` | "capture of non-Sendable type 'T.Type' / 'Value.Type' in an isolated closure." Metatypes are stateless global descriptors — inherently thread-safe. The `nonisolated(unsafe) let _: T.Type = T.self` workaround documents intent but does not suppress implicit metatype captures. Adding `& Sendable` to constraints was attempted and reverted: it caused cascade failures in downstream callers (`Ordering.Order+Swift.Comparable.swift`, etc.) where `Sendable` is not required. | ACCEPTED |
| 2 | — | `#SendableMetatypes` | `Ordering.Comparator+Comparable.swift:25` | Same diagnostic for `T: Comparison.Protocol & ~Copyable`. Adding `& Sendable` would exclude non-Sendable `~Copyable` comparable types — a legitimate use case. | ACCEPTED |
| 3 | — | `#SendableMetatypes` | `Ordering.Comparator+Projection.swift:35` | Same diagnostic for `Value: Comparison.Protocol & ~Copyable` in the `by` method. Same rationale as #2. | ACCEPTED |

### Rationale

Metatypes (`T.Type`) are pointers into read-only type metadata in the binary. They carry no mutable state and are inherently safe to share across concurrency boundaries. The Swift compiler's `#SendableMetatypes` diagnostic is conservative — it flags all metatype captures in `@Sendable` closures where the type itself is not `Sendable`. This is a known area where the type system lacks the expressivity to distinguish "the metatype of `T`" (always safe) from "a value of type `T`" (may not be safe). Future Swift evolution is expected to make metatypes unconditionally `Sendable`.

### Re-evaluation trigger

Re-evaluate when Swift adds unconditional metatype Sendability (likely via SE proposal) or when `nonisolated(unsafe)` is extended to cover implicit metatype captures.

### Summary

3 findings: 0 critical, 0 high, 0 medium, 0 low, 3 ACCEPTED. All are compiler false positives for metatype capture in `@Sendable` closures within comparator extensions. No code action possible.

### Provenance

Extracted 2026-04-08 from `swift-institute/Research/audit.md` "Accepted Compiler Warnings — 2026-03-25" (findings #1–3) per [AUDIT-002] scope location correction.

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-ordering-primitives.md (2026-03-20)

**Implementation + naming audit**

HIGH=3, MEDIUM=7, LOW=3, INFO=9
Finding IDs: ORD-001, ORD-002, ORD-003, ORD-004, ORD-005, ORD-006, ORD-007, ORD-008, ORD-009

| ID | Severity | Rule | Location | Finding |
|----|----------|------|----------|---------|
| [ORD-001] | HIGH | [API-NAME-001] | `Ordering.PartialComparator` | Compound type name `PartialComparator` |
| [ORD-002] | MEDIUM | [API-NAME-002] | `Ordering.Comparator+Projection.swift` | Compound-adjacent static factory `.by(_:using:)` — acceptable but noted |
| [ORD-003] | MEDIUM | [API-NAME-002] | `Ordering.Order+Property.View.swift:25,41,60` | Compound method names `isBefore`, `isAfter`, `isEquivalent` |
| [ORD-004] | MEDIUM | [API-NAME-002] | `Ordering.Order+Swift.Comparable.swift:35,50,65` | Same compound methods duplicated for `Swift.Comparable` |
| [ORD-005] | LOW | [API-NAME-002] | `Ordering.Comparator+Chaining.swift:51` | `then(with:)` label is mechanism-leaking; `then` alone is fine |
| [ORD-006] | INFO | [API-IMPL-005] | `Ordering.Orderable+Swift.Comparable.swift` | 14 retroactive conformances in one file — acceptable for conformance-only files |
| [ORD-007] | INFO | [API-IMPL-005] | `Ordering.Order+Swift.Comparable.swift` | Mixed content: `Property.View` extension + `Swift.Comparable` extension + `.order` property — 2 logically distinct extensions in one file |
| [ORD-008] | INFO | [IMPL-INTENT] | `Ordering.Comparator+Swift.Comparable.swift:25` | `init(swift: Void)` — mechanism-leaking disambiguation initializer |
| [ORD-009] | INFO | [IMPL-INTENT] | `Ordering.Order+Property.View.swift:29,45,64` | `unsafe base.pointee` — raw pointer access reads as mechanism, not intent |
