// OrderingTests.swift
// Tests for Ordering primitives

import Testing
@testable import Ordering_Primitives

@Suite("Ordering")
struct OrderingTests {

    // MARK: - Direction

    @Suite("Direction")
    struct DirectionTests {
        @Test
        func `All cases exist`() {
            let cases = Ordering.Direction.allCases
            #expect(cases.count == 2)
            #expect(cases.contains(.ascending))
            #expect(cases.contains(.descending))
        }

        @Test
        func `Reversal`() {
            #expect(Ordering.Direction.ascending.reversed == .descending)
            #expect(Ordering.Direction.descending.reversed == .ascending)
        }

        @Test
        func `Reversal is involution`() {
            for direction in Ordering.Direction.allCases {
                #expect(direction.reversed.reversed == direction)
            }
        }
    }

    // MARK: - Comparator Basic

    @Suite("Comparator")
    struct ComparatorTests {
        @Test
        func `Create from closure`() {
            let comparator = Ordering.Comparator<Int> { lhs, rhs in
                Comparison(comparing: lhs, to: rhs)
            }

            #expect(comparator(1, 2) == .less)
            #expect(comparator(2, 2) == .equal)
            #expect(comparator(3, 2) == .greater)
        }

        @Test
        func `callAsFunction syntax`() {
            let comparator: Ordering.Comparator<Int> = .ascending

            // Can call like a function
            let result = comparator(1, 2)
            #expect(result == .less)
        }
    }

    // MARK: - Comparator for Swift.Comparable

    @Suite("Comparator+Swift.Comparable")
    struct ComparatorSwiftComparableTests {
        @Test
        func `Ascending comparator`() {
            let comparator: Ordering.Comparator<Int> = .ascending

            #expect(comparator(1, 2) == .less)
            #expect(comparator(2, 2) == .equal)
            #expect(comparator(3, 2) == .greater)
        }

        @Test
        func `Descending comparator`() {
            let comparator: Ordering.Comparator<Int> = .descending

            #expect(comparator(1, 2) == .greater)
            #expect(comparator(2, 2) == .equal)
            #expect(comparator(3, 2) == .less)
        }

        @Test
        func `Init for Swift.Comparable`() {
            let comparator = Ordering.Comparator<String>(swift: ())

            #expect(comparator("apple", "banana") == .less)
            #expect(comparator("hello", "hello") == .equal)
            #expect(comparator("zebra", "apple") == .greater)
        }
    }

    // MARK: - Comparator Reversal

    @Suite("Comparator+Reversal")
    struct ComparatorReversalTests {
        @Test
        func `Reversed comparator`() {
            let ascending: Ordering.Comparator<Int> = .ascending
            let reversed = ascending.reversed

            #expect(reversed(1, 2) == .greater)
            #expect(reversed(2, 2) == .equal)
            #expect(reversed(3, 2) == .less)
        }

        @Test
        func `Reversal is involution`() {
            let comparator: Ordering.Comparator<Int> = .ascending
            let doubleReversed = comparator.reversed.reversed

            // Test with multiple values
            for (a, b) in [(1, 2), (2, 2), (3, 2), (0, 0), (-1, 1)] {
                #expect(comparator(a, b) == doubleReversed(a, b))
            }
        }
    }

    // MARK: - Comparator Chaining

    @Suite("Comparator+Chaining")
    struct ComparatorChainingTests {
        struct Person {
            let name: String
            let age: Int
        }

        @Test
        func `Chain with then`() {
            let byName = Ordering.Comparator<Person>.by { $0.name }
            let byAge = Ordering.Comparator<Person>.by { $0.age }
            let comparator = byName.then(byAge)

            let alice30 = Person(name: "Alice", age: 30)
            let alice25 = Person(name: "Alice", age: 25)
            let bob30 = Person(name: "Bob", age: 30)

            // Different name - byName decides
            #expect(comparator(alice30, bob30) == .less)

            // Same name, different age - byAge decides
            #expect(comparator(alice30, alice25) == .greater)

            // Same name, same age
            #expect(comparator(alice30, alice30) == .equal)
        }

        @Test
        func `Lazy chaining with then(with:)`() {
            let primary = Ordering.Comparator<Int> { lhs, rhs in
                Comparison(comparing: lhs, to: rhs)
            }

            // Secondary returns descending (reversed) ordering
            let secondary: @Sendable () -> Ordering.Comparator<Int> = {
                .descending
            }

            let chained = primary.then(with: secondary)

            // Primary is decisive - result comes from primary
            #expect(chained(1, 2) == .less)
            #expect(chained(3, 2) == .greater)

            // Primary is equal - secondary decides
            // For (2, 2), primary returns .equal, secondary (descending) also returns .equal
            #expect(chained(2, 2) == .equal)

            // Test where secondary would differ from primary
            // Create a chained comparator where secondary reverses
            let chainedWithReverse = Ordering.Comparator<Int>.ascending
                .then(with: { .descending })

            // When primary is decisive (not equal), use primary result
            #expect(chainedWithReverse(1, 2) == .less)
            #expect(chainedWithReverse(3, 2) == .greater)
        }

        @Test
        func `Associativity: (a.then(b)).then(c) = a.then(b.then(c))`() {
            struct Triple {
                let x: Int
                let y: Int
                let z: Int
            }

            let byX = Ordering.Comparator<Triple>.by { $0.x }
            let byY = Ordering.Comparator<Triple>.by { $0.y }
            let byZ = Ordering.Comparator<Triple>.by { $0.z }

            let left = byX.then(byY).then(byZ)
            let right = byX.then(byY.then(byZ))

            // Test with various triples
            let testCases: [(Triple, Triple)] = [
                (Triple(x: 1, y: 2, z: 3), Triple(x: 1, y: 2, z: 4)),
                (Triple(x: 1, y: 2, z: 3), Triple(x: 1, y: 3, z: 3)),
                (Triple(x: 1, y: 2, z: 3), Triple(x: 2, y: 2, z: 3)),
                (Triple(x: 1, y: 1, z: 1), Triple(x: 1, y: 1, z: 1)),
            ]

            for (a, b) in testCases {
                #expect(left(a, b) == right(a, b))
            }
        }
    }

    // MARK: - Comparator Projection

    @Suite("Comparator+Projection")
    struct ComparatorProjectionTests {
        struct Person {
            let name: String
            let age: Int
        }

        @Test
        func `By selector`() {
            let byAge = Ordering.Comparator<Person>.by { $0.age }

            let alice30 = Person(name: "Alice", age: 30)
            let bob25 = Person(name: "Bob", age: 25)

            #expect(byAge(alice30, bob25) == .greater)
            #expect(byAge(bob25, alice30) == .less)
        }

        @Test
        func `By selector with custom comparator`() {
            let byAgeDescending = Ordering.Comparator<Person>.by(
                { $0.age },
                using: .descending
            )

            let alice30 = Person(name: "Alice", age: 30)
            let bob25 = Person(name: "Bob", age: 25)

            #expect(byAgeDescending(alice30, bob25) == .less)
            #expect(byAgeDescending(bob25, alice30) == .greater)
        }

        @Test
        func `Complex composition`() {
            let comparator = Ordering.Comparator<Person>
                .by { $0.name }
                .then(Ordering.Comparator<Person>.by { $0.age }.reversed)

            let alice30 = Person(name: "Alice", age: 30)
            let alice25 = Person(name: "Alice", age: 25)
            let bob30 = Person(name: "Bob", age: 30)

            // Different name - name decides
            #expect(comparator(alice30, bob30) == .less)

            // Same name, age reversed - older first
            #expect(comparator(alice30, alice25) == .less)
            #expect(comparator(alice25, alice30) == .greater)
        }
    }

    // MARK: - PartialComparator

    @Suite("PartialComparator")
    struct PartialComparatorTests {
        @Test
        func `Returns result for comparable values`() {
            let comparator = Ordering.Comparator<Double>.Partial { lhs, rhs in
                if lhs.isNaN || rhs.isNaN {
                    return nil
                }
                return Comparison(comparing: lhs, to: rhs)
            }

            #expect(comparator(1.0, 2.0) == .less)
            #expect(comparator(2.0, 2.0) == .equal)
            #expect(comparator(3.0, 2.0) == .greater)
        }

        @Test
        func `Returns nil for incomparable values`() {
            let comparator = Ordering.Comparator<Double>.Partial { lhs, rhs in
                if lhs.isNaN || rhs.isNaN {
                    return nil
                }
                return Comparison(comparing: lhs, to: rhs)
            }

            #expect(comparator(Double.nan, 1.0) == nil)
            #expect(comparator(1.0, Double.nan) == nil)
            #expect(comparator(Double.nan, Double.nan) == nil)
        }
    }

    // MARK: - ~Copyable Support

    @Suite("NonCopyable Support")
    struct NonCopyableSupportTests {
        struct Token: ~Copyable, Comparison.`Protocol` {
            let id: Int

            static func < (lhs: borrowing Token, rhs: borrowing Token) -> Bool {
                lhs.id < rhs.id
            }

            static func == (lhs: borrowing Token, rhs: borrowing Token) -> Bool {
                lhs.id == rhs.id
            }
        }

        @Test
        func `Comparator with ~Copyable type`() {
            let comparator = Ordering.Comparator<Token> { lhs, rhs in
                Comparison(lhs, rhs)
            }

            let a = Token(id: 1)
            let b = Token(id: 2)
            let c = Token(id: 1)

            #expect(comparator(a, b) == .less)
            #expect(comparator(b, a) == .greater)
            #expect(comparator(a, c) == .equal)
        }

        @Test
        func `Natural ordering for Comparison.Protocol types`() {
            let comparator: Ordering.Comparator<Token> = .ascending

            let a = Token(id: 5)
            let b = Token(id: 10)

            #expect(comparator(a, b) == .less)
            #expect(comparator(b, a) == .greater)
        }

        @Test
        func `Key extraction with ~Copyable`() {
            struct Container: ~Copyable {
                let token: Token

                init(tokenId: Int) {
                    self.token = Token(id: tokenId)
                }
            }

            let byToken = Ordering.Comparator<Container>.by(
                { Comparison(comparing: $0.token.id, to: 0).isGreater ? $0.token.id : 0 },
                using: .ascending
            )

            let a = Container(tokenId: 5)
            let b = Container(tokenId: 10)

            #expect(byToken(a, b) == .less)
        }
    }

    // MARK: - Sendable

    @Suite("Sendable")
    struct SendableTests {
        @Test
        func `Comparator is Sendable`() async {
            actor TestActor {
                func compare(with comparator: Ordering.Comparator<Int>) -> Comparison {
                    comparator(1, 2)
                }
            }

            let comparator: Ordering.Comparator<Int> = .ascending
            let actor = TestActor()
            let result = await actor.compare(with: comparator)
            #expect(result == .less)
        }

        @Test
        func `Direction is Sendable`() async {
            actor TestActor {
                var direction: Ordering.Direction = .ascending
                func set(_ d: Ordering.Direction) { direction = d }
                func get() -> Ordering.Direction { direction }
            }

            let actor = TestActor()
            await actor.set(.descending)
            let result = await actor.get()
            #expect(result == .descending)
        }
    }
}
