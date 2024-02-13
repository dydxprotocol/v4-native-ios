//
//  dydxFormatterTests.swift
//  dydxFormatterTests
//
//  Created by Rui Huang on 2/27/23.
//

import XCTest
@testable import dydxFormatter

final class dydxFormatterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDollarFormatting() throws {
        struct TestCase {
            let number: Double
            let digits: Int
            let expected: String
        }

        let testCases: [TestCase] = [
            .init(number: 1, digits: 2, expected: "$1.00"),
            .init(number: -0.001, digits: 0, expected: "$0"),
            .init(number: -0.001, digits: 3, expected: "-$0.001"),
            .init(number: -0.001, digits: 2, expected: "$0.00"),
            .init(number: 0.001, digits: 2, expected: "$0.00"),
            .init(number: -0.005, digits: 2, expected: "$0.00"),
            .init(number: -0.0051, digits: 2, expected: "-$0.01")
        ]

        for testCase in testCases {
            let formatted = dydxFormatter.shared.dollar(number: testCase.number, digits: testCase.digits)
            XCTAssertEqual(formatted, testCase.expected)
        }
    }

    func testDollarVolumeFormatting() throws {
        struct TestCase {
            let number: Double
            let digits: Int
            let shouldDisplaySignForPositiveNumbers: Bool
            let expected: String
        }

        let testCases: [TestCase] = [
            .init(number: 1, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "$1.00"),
            .init(number: -0.001, digits: 0, shouldDisplaySignForPositiveNumbers: false, expected: "$0"),
            .init(number: -0.001, digits: 3, shouldDisplaySignForPositiveNumbers: false, expected: "-$0.001"),
            .init(number: -0.001, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "$0.00"),
            .init(number: 0.001, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "$0.00"),
            .init(number: -0.005, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "$0.00"),
            .init(number: -0.0051, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "-$0.01"),
            .init(number: 1, digits: 2, shouldDisplaySignForPositiveNumbers: true, expected: "+$1.00"),
            .init(number: 0, digits: 2, shouldDisplaySignForPositiveNumbers: true, expected: "$0.00"),
            .init(number: -1, digits: 2, shouldDisplaySignForPositiveNumbers: true, expected: "-$1.00")
        ]

        for testCase in testCases {
            let formatted = dydxFormatter.shared.dollarVolume(number: testCase.number, digits: testCase.digits, shouldDisplaySignForPositiveNumbers: testCase.shouldDisplaySignForPositiveNumbers)
            XCTAssertEqual(formatted, testCase.expected)
        }
    }

    func testPercentFormatting() throws {
        struct TestCase {
            let number: Double
            let digits: Int
            let shouldDisplaySignForPositiveNumbers: Bool
            let expected: String
        }

        let testCases: [TestCase] = [
            .init(number: 0.01, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "1.00%"),
            .init(number: -0.00001, digits: 0, shouldDisplaySignForPositiveNumbers: false, expected: "0%"),
            .init(number: -0.00001, digits: 3, shouldDisplaySignForPositiveNumbers: false, expected: "-0.001%"),
            .init(number: -0.00001, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "0.00%"),
            .init(number: 0.00001, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "0.00%"),
            .init(number: -0.00005, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "0.00%"),
            .init(number: -0.000051, digits: 2, shouldDisplaySignForPositiveNumbers: false, expected: "-0.01%"),
            .init(number: 0.01, digits: 2, shouldDisplaySignForPositiveNumbers: true, expected: "+1.00%"),
            .init(number: 0, digits: 2, shouldDisplaySignForPositiveNumbers: true, expected: "0.00%"),
            .init(number: -0.01, digits: 2, shouldDisplaySignForPositiveNumbers: true, expected: "-1.00%")
        ]

        for testCase in testCases {
            let formatted = dydxFormatter.shared.percent(number: testCase.number, digits: testCase.digits, shouldDisplayPlusSignForPositiveNumbers: testCase.shouldDisplaySignForPositiveNumbers)
            print(testCase)
            XCTAssertEqual(formatted, testCase.expected)
            print()
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
