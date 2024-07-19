//
//  dydxNumberInputFormatterTests.swift
//  dydxFormatterTests
//
//  Created by Michael Maguire on 7/19/24.
//

import XCTest
@testable import dydxFormatter

class dydxNumberInputFormatterTests: XCTestCase {

    func testRoundingToNearestTen() {
        let formatter = dydxNumberInputFormatter(fractionDigits: 0)
        XCTAssertEqual(formatter.format(123), "123")
        XCTAssertEqual(formatter.format(123.1), "123")
    }

    func testRoundingToNearestHundred() {
        let formatter = dydxNumberInputFormatter(fractionDigits: 2)
        XCTAssertEqual(formatter.format(123.1), "123.1")
        XCTAssertEqual(formatter.format(123.12), "123.12")
        XCTAssertEqual(formatter.format(123.123), "123.12")
    }

    func testRoundingToDecimalPlaces() {
        let formatter = dydxNumberInputFormatter(fractionDigits: -1)
        XCTAssertEqual(formatter.format(123.45), "120")
        XCTAssertEqual(formatter.format(125), "130")
        XCTAssertEqual(formatter.format(123.49999), "120")
    }

    func testTruncatingTrailingZeros() {
        let formatter = dydxNumberInputFormatter(fractionDigits: -2, shouldIncludeInsignificantZeros: false)
        XCTAssertEqual(formatter.format(123.45), "100")
        XCTAssertEqual(formatter.format(1250), "1300")
        XCTAssertEqual(formatter.format(1250.0001), "1300")
    }

    func testIncludingTrailingZeros() {
        let formatter = dydxNumberInputFormatter(fractionDigits: 2, shouldIncludeInsignificantZeros: true)
        XCTAssertEqual(formatter.format(123.1), "123.10")
        XCTAssertEqual(formatter.format(123.12), "123.12")
        XCTAssertEqual(formatter.format(123.123), "123.12")
    }

    func testStringToNumberConversion() {
        let formatter = dydxNumberInputFormatter(fractionDigits: 2)
        var number: AnyObject?
        let valid = formatter.getObjectValue(&number, for: "123.45", errorDescription: nil)
        XCTAssertTrue(valid)
        XCTAssertEqual(number?.doubleValue, 123.45)
    }

    func testInvalidStringToNumberConversion() {
        let formatter = dydxNumberInputFormatter(fractionDigits: 2)
        var number: AnyObject?
        var errorDescription: NSString?
        let valid = formatter.getObjectValue(&number, for: "abc", errorDescription: &errorDescription)
        XCTAssertFalse(valid)
        XCTAssertNotNil(errorDescription)
        XCTAssertEqual(errorDescription, "Could not convert string to number")
    }
}
