// Order Tests.swift
// Tests for Order primitives

import Testing

@testable import Order_Primitives

// MARK: - Suite Structure

@Suite
struct `Order Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit sub-suites

extension `Order Tests`.Unit {
    @Suite struct Direction {}
    @Suite struct Comparator {}
    @Suite struct `Comparator Swift.Comparable` {}
    @Suite struct `Comparator Reversal` {}
    @Suite struct `Comparator Chaining` {}
    @Suite struct `Comparator Projection` {}
    @Suite struct `Partial Comparator` {}
    @Suite struct `Noncopyable Support` {}
    @Suite struct Sendability {}
}

// MARK: - Fixtures

private struct Person {
    let name: String
    let age: Int
}

private struct Token: ~Copyable, Comparison.`Protocol` {
    let id: Int
}

extension Token {
    static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.id < rhs.id
    }

    static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.id == rhs.id
    }
}

/// Actor fixture exercising that `Order.Comparator` is Sendable across an actor boundary.
private actor Comparer {}

extension Comparer {
    func compare(with comparator: Order.Comparator<Int>) -> Comparison {
        comparator(1, 2)
    }
}

/// Actor fixture exercising that `Order.Direction` is Sendable across an actor boundary.
private actor Holder {
    var direction: Order.Direction = .ascending
}

extension Holder {
    func set(_ d: Order.Direction) { direction = d }
    func get() -> Order.Direction { direction }
}

// MARK: - Direction

extension `Order Tests`.Unit.Direction {
    @Test
    func `All cases exist`() {
        let cases = Order.Direction.allCases
        #expect(cases.count == 2)
        #expect(cases.contains(.ascending))
        #expect(cases.contains(.descending))
    }

    @Test
    func `Reversal`() {
        #expect(Order.Direction.ascending.reversed == .descending)
        #expect(Order.Direction.descending.reversed == .ascending)
    }

    @Test
    func `Reversal is involution`() {
        for direction in Order.Direction.allCases {
            #expect(direction.reversed.reversed == direction)
        }
    }
}

// MARK: - Comparator Basic

extension `Order Tests`.Unit.Comparator {
    @Test
    func `Create from closure`() {
        let comparator = Order.Comparator<Int> { lhs, rhs in
            Comparison(comparing: lhs, to: rhs)
        }

        #expect(comparator(1, 2) == .less)
        #expect(comparator(2, 2) == .equal)
        #expect(comparator(3, 2) == .greater)
    }

    @Test
    func `callAsFunction syntax`() {
        let comparator: Order.Comparator<Int> = .ascending

        // Can call like a function
        let result = comparator(1, 2)
        #expect(result == .less)
    }
}

// MARK: - Comparator for Swift.Comparable

extension `Order Tests`.Unit.`Comparator Swift.Comparable` {
    @Test
    func `Ascending comparator`() {
        let comparator: Order.Comparator<Int> = .ascending

        #expect(comparator(1, 2) == .less)
        #expect(comparator(2, 2) == .equal)
        #expect(comparator(3, 2) == .greater)
    }

    @Test
    func `Descending comparator`() {
        let comparator: Order.Comparator<Int> = .descending

        #expect(comparator(1, 2) == .greater)
        #expect(comparator(2, 2) == .equal)
        #expect(comparator(3, 2) == .less)
    }

    @Test
    func `Swift.Comparable bridging via .ascending`() {
        let comparator: Order.Comparator<String> = .ascending

        #expect(comparator("apple", "banana") == .less)
        #expect(comparator("hello", "hello") == .equal)
        #expect(comparator("zebra", "apple") == .greater)
    }
}

// MARK: - Comparator Reversal

extension `Order Tests`.Unit.`Comparator Reversal` {
    @Test
    func `Reversed comparator`() {
        let ascending: Order.Comparator<Int> = .ascending
        let reversed = ascending.reversed

        #expect(reversed(1, 2) == .greater)
        #expect(reversed(2, 2) == .equal)
        #expect(reversed(3, 2) == .less)
    }

    @Test
    func `Reversal is involution`() {
        let comparator: Order.Comparator<Int> = .ascending
        let doubleReversed = comparator.reversed.reversed

        // Test with multiple values
        for (a, b) in [(1, 2), (2, 2), (3, 2), (0, 0), (-1, 1)] {
            #expect(comparator(a, b) == doubleReversed(a, b))
        }
    }
}

// MARK: - Comparator Chaining

extension `Order Tests`.Unit.`Comparator Chaining` {
    @Test
    func `Chain with then`() {
        let byName = Order.Comparator<Person>.by { $0.name }
        let byAge = Order.Comparator<Person>.by { $0.age }
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
        let primary = Order.Comparator<Int> { lhs, rhs in
            Comparison(comparing: lhs, to: rhs)
        }

        // Secondary returns descending (reversed) ordering
        let secondary: @Sendable () -> Order.Comparator<Int> = {
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
        let chainedWithReverse = Order.Comparator<Int>.ascending
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

        let byX = Order.Comparator<Triple>.by { $0.x }
        let byY = Order.Comparator<Triple>.by { $0.y }
        let byZ = Order.Comparator<Triple>.by { $0.z }

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

extension `Order Tests`.Unit.`Comparator Projection` {
    @Test
    func `By selector`() {
        let byAge = Order.Comparator<Person>.by { $0.age }

        let alice30 = Person(name: "Alice", age: 30)
        let bob25 = Person(name: "Bob", age: 25)

        #expect(byAge(alice30, bob25) == .greater)
        #expect(byAge(bob25, alice30) == .less)
    }

    @Test
    func `By selector with custom comparator`() {
        let byAgeDescending = Order.Comparator<Person>.by(
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
        let comparator = Order.Comparator<Person>
            .by { $0.name }
            .then(Order.Comparator<Person>.by { $0.age }.reversed)

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

// MARK: - Partial Comparator

extension `Order Tests`.Unit.`Partial Comparator` {
    @Test
    func `Returns result for comparable values`() {
        let comparator = Order.Comparator<Double>.Partial { lhs, rhs in
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
        let comparator = Order.Comparator<Double>.Partial { lhs, rhs in
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

// MARK: - Noncopyable Support

extension `Order Tests`.Unit.`Noncopyable Support` {
    @Test
    func `Comparator with ~Copyable type`() {
        let comparator = Order.Comparator<Token> { lhs, rhs in
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
        let comparator: Order.Comparator<Token> = .ascending

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

        let byToken = Order.Comparator<Container>.by(
            { Comparison(comparing: $0.token.id, to: 0).isGreater ? $0.token.id : 0 },
            using: .ascending
        )

        let a = Container(tokenId: 5)
        let b = Container(tokenId: 10)

        #expect(byToken(a, b) == .less)
    }
}

// MARK: - Sendable

extension `Order Tests`.Unit.Sendability {
    @Test
    func `Comparator is Sendable`() async {
        let comparator: Order.Comparator<Int> = .ascending
        let box = Comparer()
        let result = await box.compare(with: comparator)
        #expect(result == .less)
    }

    @Test
    func `Direction is Sendable`() async {
        let box = Holder()
        await box.set(.descending)
        let result = await box.get()
        #expect(result == .descending)
    }
}
