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
        var number: Double = 1
        var digits = 2
        var formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        var expected = "$1.00"
        XCTAssertEqual(formatted, expected)

        number = -0.001
        digits = 0
        formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        expected = "$0"
        XCTAssertEqual(formatted, expected)

        number = -0.001
        digits = 2
        formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        expected = "$0.00"
        XCTAssertEqual(formatted, expected)

        number = -0.001
        digits = 3
        formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        expected = "-$0.001"
        XCTAssertEqual(formatted, expected)

        number = 0.001
        digits = 2
        formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        expected = "$0.00"
        XCTAssertEqual(formatted, expected)

        number = -0.005
        digits = 2
        formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        expected = "$0.00"
        XCTAssertEqual(formatted, expected)

        number = -0.0051
        digits = 2
        formatted = dydxFormatter.shared.dollar(number: number, digits: digits)
        expected = "-$0.01"
        XCTAssertEqual(formatted, expected)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
