// OrderingFluentAPITests.swift
// Tests for Ordering fluent API (.order property)

import Testing
@testable import Ordering_Primitives

@Suite("Ordering Fluent API")
struct OrderingFluentAPITests {

    // MARK: - Test Types

    struct Person: Ordering.Orderable {
        let name: String
        let age: Int
    }

    struct Token: ~Copyable, Ordering.Orderable, Comparison.`Protocol` {
        let id: Int

        static func < (lhs: borrowing Token, rhs: borrowing Token) -> Bool {
            lhs.id < rhs.id
        }

        static func == (lhs: borrowing Token, rhs: borrowing Token) -> Bool {
            lhs.id == rhs.id
        }
    }

    // MARK: - Copyable Type Tests

    @Suite("Copyable Types")
    struct CopyableTests {
        @Test("isBefore with explicit comparator")
        func isBefore() {
            var alice = Person(name: "Alice", age: 30)
            var bob = Person(name: "Bob", age: 25)

            let byAge = Ordering.Comparator<Person> { lhs, rhs in
                Comparison.Result(comparing: lhs.age, to: rhs.age)
            }

            #expect(alice.order.isBefore(bob, by: byAge) == false)  // 30 > 25
            #expect(bob.order.isBefore(alice, by: byAge) == true)   // 25 < 30
        }

        @Test("isAfter with explicit comparator")
        func isAfter() {
            var alice = Person(name: "Alice", age: 30)
            var bob = Person(name: "Bob", age: 25)

            let byAge = Ordering.Comparator<Person> { lhs, rhs in
                Comparison.Result(comparing: lhs.age, to: rhs.age)
            }

            #expect(alice.order.isAfter(bob, by: byAge) == true)   // 30 > 25
            #expect(bob.order.isAfter(alice, by: byAge) == false)  // 25 < 30
        }

        @Test("isEquivalent with explicit comparator")
        func isEquivalent() {
            var alice = Person(name: "Alice", age: 30)
            let carol = Person(name: "Carol", age: 30)
            let bob = Person(name: "Bob", age: 25)

            let byAge = Ordering.Comparator<Person> { lhs, rhs in
                Comparison.Result(comparing: lhs.age, to: rhs.age)
            }

            #expect(alice.order.isEquivalent(to: carol, by: byAge) == true)   // same age
            #expect(alice.order.isEquivalent(to: bob, by: byAge) == false)    // different age
        }

        @Test("Multiple comparators on same type")
        func multipleComparators() {
            var alice = Person(name: "Alice", age: 30)
            let bob = Person(name: "Bob", age: 25)

            let byAge = Ordering.Comparator<Person> { lhs, rhs in
                Comparison.Result(comparing: lhs.age, to: rhs.age)
            }
            let byName = Ordering.Comparator<Person> { lhs, rhs in
                Comparison.Result(comparing: lhs.name, to: rhs.name)
            }

            // By age: Alice(30) is after Bob(25)
            #expect(alice.order.isAfter(bob, by: byAge) == true)

            // By name: Alice comes before Bob
            #expect(alice.order.isBefore(bob, by: byName) == true)
        }
    }

    // MARK: - ~Copyable Type Tests

    @Suite("~Copyable Types")
    struct NonCopyableTests {
        @Test("isBefore with explicit comparator")
        func isBefore() {
            var a = Token(id: 5)
            var b = Token(id: 10)

            let comparator: Ordering.Comparator<Token> = .ascending

            #expect(a.order.isBefore(b, by: comparator) == true)   // 5 < 10
            #expect(b.order.isBefore(a, by: comparator) == false)  // 10 > 5
        }

        @Test("isAfter with explicit comparator")
        func isAfter() {
            var a = Token(id: 5)
            var b = Token(id: 10)

            let comparator: Ordering.Comparator<Token> = .ascending

            #expect(a.order.isAfter(b, by: comparator) == false)  // 5 < 10
            #expect(b.order.isAfter(a, by: comparator) == true)   // 10 > 5
        }

        @Test("isEquivalent with explicit comparator")
        func isEquivalent() {
            var a = Token(id: 5)
            let b = Token(id: 10)
            let c = Token(id: 5)

            let comparator: Ordering.Comparator<Token> = .ascending

            #expect(a.order.isEquivalent(to: c, by: comparator) == true)   // same id
            #expect(a.order.isEquivalent(to: b, by: comparator) == false)  // different id
        }
    }

    // MARK: - Comparison.Protocol Convenience Tests

    @Suite("Comparison.Protocol Convenience")
    struct ComparisonProtocolConvenienceTests {
        @Test("isBefore without explicit comparator")
        func isBefore() {
            var a = Token(id: 5)
            var b = Token(id: 10)

            #expect(a.order.isBefore(b) == true)   // 5 < 10 (natural ascending)
            #expect(b.order.isBefore(a) == false)  // 10 > 5
        }

        @Test("isAfter without explicit comparator")
        func isAfter() {
            var a = Token(id: 5)
            var b = Token(id: 10)

            #expect(a.order.isAfter(b) == false)  // 5 < 10 (natural ascending)
            #expect(b.order.isAfter(a) == true)   // 10 > 5
        }

        @Test("isEquivalent without explicit comparator")
        func isEquivalent() {
            var a = Token(id: 5)
            let b = Token(id: 10)
            let c = Token(id: 5)

            #expect(a.order.isEquivalent(to: c) == true)   // same id
            #expect(a.order.isEquivalent(to: b) == false)  // different id
        }
    }

    // MARK: - Descending Order Tests

    @Suite("Descending Order")
    struct DescendingOrderTests {
        @Test("isBefore with descending comparator")
        func isBeforeDescending() {
            var a = Token(id: 5)
            var b = Token(id: 10)

            let descending: Ordering.Comparator<Token> = .descending

            // In descending order, larger values come first
            // So 5 is AFTER 10 in descending order
            #expect(a.order.isBefore(b, by: descending) == false)
            #expect(b.order.isBefore(a, by: descending) == true)
        }

        @Test("isAfter with descending comparator")
        func isAfterDescending() {
            var a = Token(id: 5)
            var b = Token(id: 10)

            let descending: Ordering.Comparator<Token> = .descending

            // In descending order, smaller values come later
            // So 5 is AFTER 10 in descending order
            #expect(a.order.isAfter(b, by: descending) == true)
            #expect(b.order.isAfter(a, by: descending) == false)
        }
    }

    // MARK: - Orderable Protocol Tests

    @Suite("Orderable Protocol")
    struct OrderableProtocolTests {
        @Test("Type conforming to Orderable gets .order property")
        func orderableGetsOrderProperty() {
            struct SimpleValue: Ordering.Orderable {
                let x: Int
            }

            var value = SimpleValue(x: 10)
            let other = SimpleValue(x: 5)

            let comparator = Ordering.Comparator<SimpleValue> { lhs, rhs in
                Comparison.Result(comparing: lhs.x, to: rhs.x)
            }

            #expect(value.order.isAfter(other, by: comparator) == true)
        }

        @Test("~Copyable type can conform to Orderable")
        func nonCopyableOrderable() {
            struct Resource: ~Copyable, Ordering.Orderable {
                let priority: Int
            }

            var high = Resource(priority: 10)
            let low = Resource(priority: 1)

            let byPriority = Ordering.Comparator<Resource> { lhs, rhs in
                Comparison.Result(comparing: lhs.priority, to: rhs.priority)
            }

            #expect(high.order.isAfter(low, by: byPriority) == true)
        }
    }

    // MARK: - Standard Type Conformances

    @Suite("Standard Type Conformances")
    struct StandardTypeConformancesTests {
        @Test("Int has .order property")
        func intOrderable() {
            var a = 5
            let b = 10

            // Int conforms to Comparison.Protocol, so convenience methods work
            #expect(a.order.isBefore(b) == true)
            #expect(a.order.isAfter(b) == false)
        }

        @Test("String has .order property with explicit comparator")
        func stringOrderable() {
            var apple = "apple"
            let banana = "banana"

            let comparator: Ordering.Comparator<String> = .swiftAscending

            #expect(apple.order.isBefore(banana, by: comparator) == true)
            #expect(apple.order.isAfter(banana, by: comparator) == false)
        }

        @Test("Double has .order property with explicit comparator")
        func doubleOrderable() {
            var a = 1.5
            let b = 2.5

            let comparator: Ordering.Comparator<Double> = .swiftAscending

            #expect(a.order.isBefore(b, by: comparator) == true)
            #expect(a.order.isAfter(b, by: comparator) == false)
        }

        @Test("UInt8 has .order property with convenience methods")
        func uint8Orderable() {
            var a: UInt8 = 100
            let b: UInt8 = 200

            // UInt8 conforms to Comparison.Protocol, so convenience methods work
            #expect(a.order.isBefore(b) == true)
            #expect(a.order.isEquivalent(to: a) == true)
        }
    }
}
