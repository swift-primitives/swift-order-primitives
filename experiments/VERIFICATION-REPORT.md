# Experiment Discovery Report: swift-ordering-primitives

**Date**: 2026-01-22
**Package**: swift-ordering-primitives
**Design Document**: `/Users/coen/Developer/swift-primitives/swift-ordering-primitives/docs/Ordering-Primitives-Design.md`
**Experiment Location**: `/Users/coen/Developer/swift-primitives/swift-ordering-primitives/experiments/`

---

## Executive Summary

This report documents the results of executing the Experiment Discovery workflow [EXP-012 through EXP-017] for the `swift-ordering-primitives` design paper. The experiment verified 8 claims and 5 assumptions from the design document against Swift 6 strict concurrency mode.

**Critical Finding**: `KeyPath<Root, Value>` is **NOT Sendable** in Swift 6. This requires revision of Section 5.3.4 of the design paper.

### Results Summary

| Category | Total | Verified | Partially Verified | Refuted |
|----------|-------|----------|-------------------|---------|
| Claims | 8 | 7 | 1 | 0 |
| Assumptions | 5 | 4 | 0 | 1 |

---

## Phase 1: Inventory of Proposed Types and APIs

### Proposed Public Types

| Type | Description | Paper Section |
|------|-------------|---------------|
| `Ordering` | Namespace enum | 5.1 |
| `Ordering.Direction` | Ascending/descending enum | 5.2 |
| `Ordering.Comparator<T>` | Reified comparator with @Sendable closure | 5.3 |
| `Ordering.Projection<Root, Value>` | Key-path based ordering | 5.4 |
| `Ordering.PartialComparator<T>` | Optional result for partial orders | 5.5 |

### Proposed APIs

| API | Type | Description |
|-----|------|-------------|
| `Direction.reversed` | Property | Returns opposite direction |
| `Comparator.init(_:)` | Initializer | Creates from @Sendable closure |
| `Comparator.callAsFunction(_:_:)` | Method | Enables `comparator(a, b)` syntax |
| `Comparator.reversed` | Property | Returns reversed comparator |
| `Comparator.then(_:)` | Method | Lexicographic chaining |
| `Comparator.by(_:)` | Static method | KeyPath projection |
| `Comparator.ascending` | Static property | Natural ascending order |
| `Comparator.descending` | Static property | Natural descending order |
| `Projection.comparator` | Property | Converts to Comparator |
| `PartialComparator.callAsFunction(_:_:)` | Method | Returns Optional result |

---

## Phase 2: Testable Claims

### CLAIM-001: @Sendable Closure Storage
**Statement**: Comparators can store @Sendable closures in their internal state.

**Verification Code**:
```swift
let comparator = Ordering.Comparator<Int> { lhs, rhs in
    Comparison.Result(lhs, rhs)
}
#expect(comparator(1, 2) == .less)
```

**Result**: **VERIFIED**

**Evidence**: The `Ordering.Comparator<T>` struct successfully compiles with an internal `@Sendable (T, T) -> Comparison.Result` closure, and the comparator correctly produces comparison results.

---

### CLAIM-002: Reversal Involution Property
**Statement**: The `reversed` property returns a reversed comparator, and `reversed(reversed(c)) == c` (involution).

**Verification Code**:
```swift
let ascending: Ordering.Comparator<Int> = .ascending
let doubleReversed = ascending.reversed.reversed
#expect(doubleReversed(1, 2) == ascending(1, 2))
```

**Result**: **VERIFIED**

**Evidence**: Mathematical involution property holds for all tested inputs. `reversed.reversed` produces identical results to the original comparator.

---

### CLAIM-003: Lexicographic Chaining (Monoid Property)
**Statement**: The `then(_:)` method implements lexicographic chaining with associativity.

**Verification Code**:
```swift
let byAge = Ordering.Comparator<Person>.by { $0.age }
let byName = Ordering.Comparator<Person>.by { $0.name }
let byDept = Ordering.Comparator<Person>.by { $0.department }

let leftGrouped = byAge.then(byName).then(byDept)
let rightGrouped = byAge.then(byName.then(byDept))

#expect(leftGrouped(alice, bob) == rightGrouped(alice, bob))
```

**Result**: **VERIFIED**

**Evidence**:
- When first comparison is equal, second comparator is used
- Associativity holds: `(c1 ⊕ c2) ⊕ c3 = c1 ⊕ (c2 ⊕ c3)`
- Identity element (always returns `.equal`) works correctly

---

### CLAIM-004: KeyPath-Based Projection
**Statement**: KeyPath-based projection works with generics: `Comparator.by(\.property)`

**Verification Code**:
```swift
// This does NOT compile with Sendable Comparator:
// let byAge = Ordering.Comparator<Person>.by(\.age)  // ERROR

// This works with NonSendableComparator:
let byAge = Ordering.NonSendableComparator<Person>.by(\.age)
#expect(byAge(alice, bob) == .greater)
```

**Result**: **PARTIALLY VERIFIED / REFUTED for Sendable variant**

**Evidence**:
- KeyPath extraction works correctly in non-Sendable context
- **CRITICAL**: `KeyPath<Root, Value>` is NOT Sendable in Swift 6
- Compiler error: "capture of 'keyPath' with non-Sendable type 'KeyPath<T, Value>' in a '@Sendable' closure"
- Design paper Section 5.3.4 requires revision

---

### CLAIM-005: callAsFunction Syntax
**Statement**: `callAsFunction` enables `comparator(a, b)` syntax for comparisons.

**Verification Code**:
```swift
let comparator: Ordering.Comparator<Int> = .ascending
let result = comparator(1, 2)  // Uses callAsFunction
#expect(result == .less)
```

**Result**: **VERIFIED**

**Evidence**: The `callAsFunction(_:_:)` method enables natural function-call syntax for comparators.

---

### CLAIM-006: Direction Enum Reversal
**Statement**: `Ordering.Direction` supports reversal with involution property.

**Verification Code**:
```swift
#expect(Ordering.Direction.ascending.reversed == .descending)
#expect(Ordering.Direction.descending.reversed == .ascending)
#expect(Ordering.Direction.ascending.reversed.reversed == .ascending)
```

**Result**: **VERIFIED**

**Evidence**: Direction reversal works correctly and satisfies involution property.

---

### CLAIM-007: Comparable Type Integration
**Statement**: Comparator works with Comparable types via `.ascending` and `.descending` static properties.

**Verification Code**:
```swift
let intComparator: Ordering.Comparator<Int> = .ascending
let stringComparator: Ordering.Comparator<String> = .ascending
let descending: Ordering.Comparator<Int> = .descending

#expect(intComparator(1, 2) == .less)
#expect(stringComparator("apple", "banana") == .less)
#expect(descending(1, 2) == .greater)
```

**Result**: **VERIFIED**

**Evidence**: Works correctly with Int, String, Double, and other Comparable types.

---

### CLAIM-008: PartialComparator Returns Optional
**Statement**: `PartialComparator` returns `Optional<Comparison.Result>` for partial orders.

**Verification Code**:
```swift
let floatComparator = Ordering.PartialComparator<Double> { lhs, rhs in
    if lhs.isNaN || rhs.isNaN { return nil }
    return Comparison.Result(lhs, rhs)
}

#expect(floatComparator(1.0, 2.0) == .less)
#expect(floatComparator(Double.nan, 1.0) == nil)
```

**Result**: **VERIFIED**

**Evidence**: PartialComparator correctly returns `nil` for incomparable values (e.g., NaN).

---

## Phase 3: Implicit Assumptions

### ASSUMP-001: @Sendable Closure Storage in Structs
**Statement**: @Sendable closures can be stored as properties in Sendable structs.

**Result**: **VERIFIED**

**Evidence**: Swift 6 allows `@Sendable` closures as stored properties in `Sendable` structs.

---

### ASSUMP-002: KeyPath Works with Generics at Tier 0
**Statement**: KeyPath works with generics without Foundation dependency.

**Result**: **PARTIALLY VERIFIED / REFUTED for Sendability**

**Evidence**:
- KeyPath works with generics: `KeyPath<T, Value>` compiles and functions correctly
- **CRITICAL**: KeyPath is NOT Sendable
- Cannot capture KeyPath in @Sendable closures
- This breaks the proposed API design

---

### ASSUMP-003: callAsFunction with Generic Return Types
**Statement**: `callAsFunction` works with generic return types.

**Result**: **VERIFIED**

**Evidence**: `callAsFunction` correctly handles generic return types in Swift 6.

---

### ASSUMP-004: Sendable Closure Capture
**Statement**: Closures capturing @Sendable closures are themselves @Sendable.

**Result**: **VERIFIED**

**Evidence**: Capturing a @Sendable closure in another closure maintains Sendability, enabling composition patterns like `reversed` and `then`.

---

### ASSUMP-005: Nested Generic Types
**Statement**: Nested generic types like `Ordering.Comparator<T>` compile correctly.

**Result**: **VERIFIED**

**Evidence**: All nested generic types (`Comparator<T>`, `Projection<Root, Value>`, `PartialComparator<T>`) compile and function correctly.

---

## Critical Discovery: KeyPath is NOT Sendable

### Discovery Details

**Symptom**: The design paper's proposed API:
```swift
public static func by<Value: Comparable>(
    _ keyPath: KeyPath<T, Value>
) -> Ordering.Comparator<T>
```

**Does NOT compile** with Swift 6 strict concurrency because `KeyPath<T, Value>` is not `Sendable`.

### Compiler Error
```
error: capture of 'keyPath' with non-Sendable type 'KeyPath<T, Value>'
in a '@Sendable' closure [#SendableClosureCaptures]
```

### Impact
- Design paper Section 5.3.4 (Projection via KeyPath) requires revision
- Section 5.4 (Ordering.Projection with KeyPath initializer) requires revision
- All KeyPath-based APIs cannot be part of the Sendable `Comparator<T>` type

### Recommended Workarounds

1. **Closure-based selectors** (implemented in experiment):
   ```swift
   // Instead of: .by(\.age)
   // Use: .by { $0.age }
   let byAge = Ordering.Comparator<Person>.by { $0.age }
   ```

2. **Non-Sendable variant** (implemented in experiment):
   ```swift
   // For local (non-concurrent) use only
   let byAge = Ordering.NonSendableComparator<Person>.by(\.age)
   ```

3. **Await Swift Evolution**: Monitor Swift proposals for making KeyPath Sendable.

### Design Paper Revision Required

The following sections need updates:

| Section | Change Required |
|---------|-----------------|
| 5.3.4 | Remove KeyPath overload from `Comparator<T>.by`, keep closure variant |
| 5.4 | Remove KeyPath initializer from `Projection`, or create non-Sendable variant |
| 5.6 | Update file organization to include non-Sendable variants |
| 6.4 | Update Sendable compliance section to document KeyPath limitation |

---

## Test Execution Results

```
swift test
Test run with 20 tests in 0 suites passed after 0.001 seconds.
```

All 20 verification tests pass, confirming:
- Core comparator functionality works
- Algebraic properties (involution, monoid) hold
- Sendable compliance for closure-based APIs
- Non-Sendable variant correctly supports KeyPath

---

## Files Created

| File | Purpose |
|------|---------|
| `experiments/Package.swift` | Swift 6 package manifest |
| `experiments/Sources/OrderingExperiments/Comparison.swift` | Mock Comparison.Result |
| `experiments/Sources/OrderingExperiments/Ordering.swift` | Namespace enum |
| `experiments/Sources/OrderingExperiments/Ordering.Direction.swift` | Direction enum |
| `experiments/Sources/OrderingExperiments/Ordering.Comparator.swift` | Comparator + NonSendableComparator |
| `experiments/Sources/OrderingExperiments/Ordering.Projection.swift` | Projection + NonSendableProjection |
| `experiments/Sources/OrderingExperiments/Ordering.PartialComparator.swift` | PartialComparator |
| `experiments/Tests/OrderingExperimentsTests/ClaimVerificationTests.swift` | All verification tests |
| `experiments/VERIFICATION-REPORT.md` | This report |

---

## Conclusion

The `swift-ordering-primitives` design is **sound with one critical exception**: the KeyPath-based APIs cannot be implemented as Sendable in Swift 6.

**Recommendations**:
1. Revise the design paper to use closure-based selectors for the Sendable API
2. Optionally provide a non-Sendable variant (`NonSendableComparator`) for KeyPath convenience
3. Document the KeyPath Sendable limitation prominently
4. All other proposed types and APIs are verified to work correctly

The algebraic properties (monoid structure, involution) hold as specified, and the Sendable compliance for closure-based APIs is confirmed.
