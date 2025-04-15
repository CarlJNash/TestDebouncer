//
//  TestDebouncerTests.swift
//  TestDebouncerTests
//
//  Created by Carl Nash on 14/04/2025.
//

import XCTest
@testable import TestDebouncer

final class TestDebouncerTests: XCTestCase {

    var sut: Debouncer!

    override func setUp() {
        sut = Debouncer(delay: 1)
    }

    func testDebouncerWaitsForSpecifiedDelay() async throws {
        // GIVEN
        var value = 0
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        // WHEN
        await sut.debounce() {
            value += 1
            expectation.fulfill()
        }

        // THEN
        // value should still be 0
        XCTAssertEqual(value, 0)
        // wait until debounce delay has passed
        try await Task.sleep(for: .seconds(1.1))
        XCTAssertEqual(value, 1)
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testDebouncerMultipleCallsIgnoresFirstTwo() async throws {
        // GIVEN
        var value = 0
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        // WHEN
        await sut.debounce() {
            value += 1
            expectation.fulfill()
            XCTFail("Should not be called")
        }
        await sut.debounce() {
            value += 1
            expectation.fulfill()
            XCTFail("Should not be called")
        }
        await sut.debounce() {
            value += 1
            expectation.fulfill()
        }

        // THEN
        // should still be 0
        XCTAssertEqual(value, 0)
        try await Task.sleep(for: .seconds(1.1))
        await fulfillment(of: [expectation], timeout: 3)
        // value should be 1 as the first 2 calls should have been cancelled by the third
        XCTAssertEqual(value, 1)
    }

    func testDebouncerMultipleCallsIgnoresSecond() async throws {
        // GIVEN
        var value = 0
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true

        // WHEN
        await sut.debounce() {
            value += 1
            expectation.fulfill()
        }
        // wait for the debouncer function be called
        try await Task.sleep(for: .seconds(1.1))

        await sut.debounce() {
            value += 1
            expectation.fulfill()
            XCTFail("Should not be called")
        }

        await sut.debounce() {
            value += 1
            expectation.fulfill()
        }

        // THEN
        // should be 1 as we waited above
        XCTAssertEqual(value, 1)
        try await Task.sleep(for: .seconds(1.1))
        // value should now be 2 as the second call should have been cancelled by the third
        XCTAssertEqual(value, 2)
        await fulfillment(of: [expectation], timeout: 3)
    }

    func testDebouncerOverrideDelay() async throws {
        // GIVEN
        var value = 0
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true

        // WHEN
        // default delay
        await sut.debounce {
            value += 1
            expectation.fulfill()
        }

        // THEN
        // value should still be 0
        XCTAssertEqual(value, 0)
        // wait until debounce delay has passed
        try await Task.sleep(for: .seconds(1.1))
        XCTAssertEqual(value, 1)

        // override delay
        await sut.debounce(overrideDelay: 2) {
            value += 1
            expectation.fulfill()
        }
        try await Task.sleep(for: .seconds(1.1))
        // value should still be 1 as 2 second delay hasn't passed
        XCTAssertEqual(value, 1)

        // wait for another second
        try await Task.sleep(for: .seconds(1.1))
        // value should now be 2
        XCTAssertEqual(value, 2)

        await fulfillment(of: [expectation], timeout: 5)
    }

}
