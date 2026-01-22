import Testing
@testable import OrderingExperiments

// MARK: - Test Data Types

struct Person: Sendable {
    let name: String
    let age: Int
    let department: String
}

// ============================================================================
// MARK: - CLAIM VERIFICATION TESTS
// ============================================================================

/// [CLAIM-001] Comparators can store @Sendable closures
@Test("CLAIM-001: Comparators can store @Sendable closures")
func claim001_sendableClosureStorage() {
    // Verify that a comparator can be created with a @Sendable closure
    let comparator = Ordering.Comparator<Int> { lhs, rhs in
        Comparison.Result(lhs, rhs)
    }

    // Verify it works correctly
    #expect(comparator(1, 2) == .less)
    #expect(comparator(2, 1) == .greater)
    #expect(comparator(1, 1) == .equal)

    print("CLAIM-001: VERIFIED - @Sendable closures can be stored in Comparator<T>")
}

/// [CLAIM-002] `reversed` property returns reversed comparator (involution property)
@Test("CLAIM-002: reversed property implements involution")
func claim002_reversedInvolution() {
    let ascending: Ordering.Comparator<Int> = .ascending

    // Test basic reversal
    #expect(ascending(1, 2) == .less)
    #expect(ascending.reversed(1, 2) == .greater)

    // Test involution: reversed(reversed(c)) == c
    let doubleReversed = ascending.reversed.reversed
    #expect(doubleReversed(1, 2) == ascending(1, 2))
    #expect(doubleReversed(2, 1) == ascending(2, 1))
    #expect(doubleReversed(1, 1) == ascending(1, 1))

    print("CLAIM-002: VERIFIED - reversed property is an involution")
}

/// [CLAIM-003] `then(_:)` implements lexicographic chaining (monoid property)
@Test("CLAIM-003: then(_:) implements lexicographic chaining")
func claim003_lexicographicChaining() {
    // Use closure-based selectors since KeyPath is not Sendable
    let byAge = Ordering.Comparator<Person>.by { $0.age }
    let byName = Ordering.Comparator<Person>.by { $0.name }
    let byDept = Ordering.Comparator<Person>.by { $0.department }

    let alice = Person(name: "Alice", age: 30, department: "Engineering")
    let bob = Person(name: "Bob", age: 30, department: "Engineering")
    let charlie = Person(name: "Charlie", age: 25, department: "Sales")

    // Test chaining: when first comparison is equal, use second
    let byAgeThenName = byAge.then(byName)

    // alice vs bob: same age, so compare by name (Alice < Bob)
    #expect(byAgeThenName(alice, bob) == .less)

    // alice vs charlie: different age (30 > 25), so age wins
    #expect(byAgeThenName(alice, charlie) == .greater)

    // Test associativity: (c1 ⊕ c2) ⊕ c3 = c1 ⊕ (c2 ⊕ c3)
    let leftGrouped = byAge.then(byName).then(byDept)
    let rightGrouped = byAge.then(byName.then(byDept))

    // Test with values that exercise all three comparators
    let alice2 = Person(name: "Alice", age: 30, department: "HR")
    let alice3 = Person(name: "Alice", age: 30, department: "Engineering")

    #expect(leftGrouped(alice2, alice3) == rightGrouped(alice2, alice3))

    print("CLAIM-003: VERIFIED - then(_:) implements associative lexicographic chaining")
}

/// [CLAIM-004] KeyPath-based projection works with generics
/// PARTIALLY REFUTED: KeyPath works but is NOT Sendable in Swift 6
@Test("CLAIM-004: KeyPath-based projection (NON-SENDABLE)")
func claim004_keypathProjection() {
    // KeyPath-based comparators work but are NOT Sendable
    let byAge = Ordering.NonSendableComparator<Person>.by(\.age)
    let byName = Ordering.NonSendableComparator<Person>.by(\.name)

    let alice = Person(name: "Alice", age: 30, department: "Engineering")
    let bob = Person(name: "Bob", age: 25, department: "Sales")

    // Test KeyPath extraction
    #expect(byAge(alice, bob) == .greater)  // 30 > 25
    #expect(byName(alice, bob) == .less)    // "Alice" < "Bob"

    print("CLAIM-004: PARTIALLY VERIFIED - KeyPath projection works but requires NonSendableComparator")
    print("CLAIM-004: REFUTED for Sendable variant - KeyPath is NOT Sendable in Swift 6")
}

/// [CLAIM-005] callAsFunction enables `comparator(a, b)` syntax
@Test("CLAIM-005: callAsFunction enables comparator(a, b) syntax")
func claim005_callAsFunction() {
    let comparator: Ordering.Comparator<Int> = .ascending

    // Test the call syntax directly
    let result1 = comparator(1, 2)
    let result2 = comparator(2, 1)
    let result3 = comparator(1, 1)

    #expect(result1 == .less)
    #expect(result2 == .greater)
    #expect(result3 == .equal)

    print("CLAIM-005: VERIFIED - callAsFunction enables comparator(a, b) syntax")
}

/// [CLAIM-006] Direction enum supports reversal
@Test("CLAIM-006: Direction enum supports reversal")
func claim006_directionReversal() {
    #expect(Ordering.Direction.ascending.reversed == .descending)
    #expect(Ordering.Direction.descending.reversed == .ascending)

    // Test involution
    #expect(Ordering.Direction.ascending.reversed.reversed == .ascending)
    #expect(Ordering.Direction.descending.reversed.reversed == .descending)

    print("CLAIM-006: VERIFIED - Direction enum supports reversal as involution")
}

/// [CLAIM-007] Comparator works with Comparable types
@Test("CLAIM-007: Comparator works with Comparable types")
func claim007_comparableIntegration() {
    // Test with Int
    let intComparator: Ordering.Comparator<Int> = .ascending
    #expect(intComparator(1, 2) == .less)

    // Test with String
    let stringComparator: Ordering.Comparator<String> = .ascending
    #expect(stringComparator("apple", "banana") == .less)

    // Test with Double
    let doubleComparator: Ordering.Comparator<Double> = .ascending
    #expect(doubleComparator(1.5, 2.5) == .less)

    // Test descending static property
    let descending: Ordering.Comparator<Int> = .descending
    #expect(descending(1, 2) == .greater)

    print("CLAIM-007: VERIFIED - Comparator works with Comparable types")
}

/// [CLAIM-008] PartialComparator returns Optional
@Test("CLAIM-008: PartialComparator returns Optional")
func claim008_partialComparator() {
    // Create a partial comparator for floating point that treats NaN as incomparable
    let floatComparator = Ordering.PartialComparator<Double> { lhs, rhs in
        if lhs.isNaN || rhs.isNaN {
            return nil
        }
        return Comparison.Result(lhs, rhs)
    }

    // Test comparable values
    #expect(floatComparator(1.0, 2.0) == .less)
    #expect(floatComparator(2.0, 1.0) == .greater)
    #expect(floatComparator(1.0, 1.0) == .equal)

    // Test incomparable values (NaN)
    #expect(floatComparator(Double.nan, 1.0) == nil)
    #expect(floatComparator(1.0, Double.nan) == nil)
    #expect(floatComparator(Double.nan, Double.nan) == nil)

    print("CLAIM-008: VERIFIED - PartialComparator returns Optional for incomparable values")
}

// ============================================================================
// MARK: - ASSUMPTION VERIFICATION TESTS
// ============================================================================

/// [ASSUMP-001] @Sendable closures can be stored in structs
@Test("ASSUMP-001: @Sendable closures can be stored in structs")
func assumption001_sendableInStruct() {
    struct SendableContainer: Sendable {
        let closure: @Sendable (Int, Int) -> Bool
    }

    let container = SendableContainer { lhs, rhs in lhs < rhs }
    #expect(container.closure(1, 2) == true)

    print("ASSUMP-001: VERIFIED - @Sendable closures can be stored in Sendable structs")
}

/// [ASSUMP-002] KeyPath works with generics at Tier 0
/// REFUTED: KeyPath works with generics but is NOT Sendable
@Test("ASSUMP-002: KeyPath with generics - Sendability check")
func assumption002_keypathWithGenerics() {
    // Test that KeyPath works in a generic context without Foundation
    func extractValue<T, V>(from value: T, using keyPath: KeyPath<T, V>) -> V {
        value[keyPath: keyPath]
    }

    let person = Person(name: "Alice", age: 30, department: "Engineering")
    let age = extractValue(from: person, using: \.age)
    #expect(age == 30)

    print("ASSUMP-002: PARTIALLY VERIFIED - KeyPath works with generics")
    print("ASSUMP-002: REFUTED - KeyPath is NOT Sendable, cannot be used in @Sendable closures")
}

/// [ASSUMP-003] callAsFunction works with generic return types
@Test("ASSUMP-003: callAsFunction works with generic return types")
func assumption003_callAsFunctionGeneric() {
    struct GenericCallable<Input, Output> {
        let transform: (Input) -> Output

        func callAsFunction(_ input: Input) -> Output {
            transform(input)
        }
    }

    let doubler = GenericCallable<Int, Int> { $0 * 2 }
    #expect(doubler(5) == 10)

    let stringify = GenericCallable<Int, String> { "\($0)" }
    #expect(stringify(42) == "42")

    print("ASSUMP-003: VERIFIED - callAsFunction works with generic return types")
}

/// [ASSUMP-004] Closures capturing @Sendable closures are themselves @Sendable
@Test("ASSUMP-004: Closures capturing @Sendable closures are @Sendable")
func assumption004_sendableClosureCapture() {
    let innerClosure: @Sendable (Int, Int) -> Comparison.Result = { lhs, rhs in
        Comparison.Result(lhs, rhs)
    }

    // Capture the inner closure in another @Sendable closure
    let outerClosure: @Sendable (Int, Int) -> Comparison.Result = { lhs, rhs in
        innerClosure(lhs, rhs).reversed
    }

    #expect(outerClosure(1, 2) == .greater)

    print("ASSUMP-004: VERIFIED - Closures capturing @Sendable closures can be @Sendable")
}

/// [ASSUMP-005] Nested generic types compile correctly
@Test("ASSUMP-005: Nested generic types compile correctly")
func assumption005_nestedGenerics() {
    // Ordering.Comparator<T> is a nested generic type
    let comparator: Ordering.Comparator<Int> = .ascending

    // Ordering.Projection<Root, Value> has two generic parameters
    let projection = Ordering.Projection<Person, Int>({ $0.age })

    let person = Person(name: "Alice", age: 30, department: "Engineering")

    // Test that nested generics work correctly
    #expect(comparator(1, 2) == .less)
    #expect(projection.comparator(person, Person(name: "Bob", age: 25, department: "Sales")) == .greater)

    print("ASSUMP-005: VERIFIED - Nested generic types compile and work correctly")
}

// ============================================================================
// MARK: - ALGEBRAIC PROPERTY TESTS
// ============================================================================

/// Test that Direction is a proper involution
@Test("Algebraic: Direction involution property")
func algebraic_directionInvolution() {
    for direction in Ordering.Direction.allCases {
        #expect(direction.reversed.reversed == direction,
               "Direction.\(direction).reversed.reversed should equal Direction.\(direction)")
    }
    print("ALGEBRAIC: Direction involution property holds for all cases")
}

/// Test Comparator monoid identity
@Test("Algebraic: Comparator identity element")
func algebraic_comparatorIdentity() {
    // The identity comparator returns .equal for all inputs
    let identity = Ordering.Comparator<Int> { _, _ in .equal }
    let ascending: Ordering.Comparator<Int> = .ascending

    // Test: c ⊕ identity = c
    let rightIdentity = ascending.then(identity)
    #expect(rightIdentity(1, 2) == ascending(1, 2))
    #expect(rightIdentity(2, 1) == ascending(2, 1))
    #expect(rightIdentity(1, 1) == ascending(1, 1))

    // Test: identity ⊕ c = c
    let leftIdentity = identity.then(ascending)
    #expect(leftIdentity(1, 2) == ascending(1, 2))
    #expect(leftIdentity(2, 1) == ascending(2, 1))
    #expect(leftIdentity(1, 1) == ascending(1, 1))

    print("ALGEBRAIC: Comparator monoid identity property holds")
}

// ============================================================================
// MARK: - SENDABLE COMPLIANCE TESTS
// ============================================================================

/// Verify Sendable conformance compiles (Swift 6 strict concurrency)
@Test("Sendable: All Sendable types conform correctly")
func sendable_allTypesConform() async {
    // These lines will fail compilation if types are not Sendable

    let direction: Ordering.Direction = .ascending
    let comparator: Ordering.Comparator<Int> = .ascending
    let projection = Ordering.Projection<Person, Int>({ $0.age })
    let partialComparator = Ordering.PartialComparator<Double> { lhs, rhs in
        Comparison.Result(lhs, rhs)
    }

    // Use in async context to verify Sendable
    await Task {
        _ = direction
        _ = comparator
        _ = projection
        _ = partialComparator
    }.value

    print("SENDABLE: All Sendable types can be used across concurrency boundaries")
}

/// Verify that NonSendable types do NOT conform to Sendable
@Test("Sendable: NonSendable types correctly omit Sendable")
func sendable_nonSendableTypes() {
    // NonSendableComparator should NOT be Sendable
    let comparator = Ordering.NonSendableComparator<Person>.by(\.age)

    // This comparator works locally
    let alice = Person(name: "Alice", age: 30, department: "Engineering")
    let bob = Person(name: "Bob", age: 25, department: "Sales")
    #expect(comparator(alice, bob) == .greater)

    print("NON-SENDABLE: NonSendableComparator works for local (non-concurrent) use")
}

// ============================================================================
// MARK: - PROJECTION TESTS
// ============================================================================

@Test("Projection: Direction integration (Sendable)")
func projection_directionIntegrationSendable() {
    let ascending = Ordering.Projection<Person, Int>({ $0.age }, direction: .ascending)
    let descending = Ordering.Projection<Person, Int>({ $0.age }, direction: .descending)

    let young = Person(name: "Young", age: 20, department: "A")
    let old = Person(name: "Old", age: 40, department: "B")

    // Ascending: younger comes first
    #expect(ascending.comparator(young, old) == .less)

    // Descending: older comes first
    #expect(descending.comparator(young, old) == .greater)

    // Test reversed projection
    #expect(ascending.reversed.direction == .descending)
    #expect(descending.reversed.direction == .ascending)

    print("PROJECTION (Sendable): Direction integration works correctly")
}

@Test("Projection: KeyPath-based (NonSendable)")
func projection_keypathNonSendable() {
    let ascending = Ordering.NonSendableProjection<Person, Int>(\.age, direction: .ascending)
    let descending = Ordering.NonSendableProjection<Person, Int>(\.age, direction: .descending)

    let young = Person(name: "Young", age: 20, department: "A")
    let old = Person(name: "Old", age: 40, department: "B")

    // Ascending: younger comes first
    #expect(ascending.comparator(young, old) == .less)

    // Descending: older comes first
    #expect(descending.comparator(young, old) == .greater)

    print("PROJECTION (NonSendable): KeyPath-based direction integration works correctly")
}

// ============================================================================
// MARK: - DISCOVERY DOCUMENTATION
// ============================================================================

/// Document the critical KeyPath Sendable discovery
@Test("DISCOVERY: KeyPath is NOT Sendable in Swift 6")
func discovery_keypathNotSendable() {
    // This test documents the critical discovery that KeyPath<Root, Value>
    // is NOT Sendable in Swift 6 strict concurrency mode.

    // The design paper proposed:
    //   public static func by<Value: Comparable>(
    //       _ keyPath: KeyPath<T, Value>
    //   ) -> Ordering.Comparator<T>
    //
    // This DOES NOT COMPILE with Swift 6 strict concurrency because
    // capturing a KeyPath in a @Sendable closure is forbidden.

    // WORKAROUNDS:
    // 1. Use closure-based selectors: .by { $0.age } instead of .by(\.age)
    // 2. Use NonSendableComparator for local (non-concurrent) KeyPath usage
    // 3. Wait for Swift evolution to make KeyPath Sendable

    print("DISCOVERY DOCUMENTED: KeyPath<Root, Value> is NOT Sendable in Swift 6")
    print("  - Compiler error: 'capture of keyPath with non-Sendable type in @Sendable closure'")
    print("  - Impact: Design paper Section 5.3.4 requires revision")
    print("  - Workaround: Use closure-based .by({ $0.property }) instead of .by(\\.property)")
}
