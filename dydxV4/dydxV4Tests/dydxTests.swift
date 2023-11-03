//
//  dydxTests.swift
//  dydxTests
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Abacus
import JavaScriptCore
import XCTest

class dydxTests: XCTestCase {
    func test_abacus() {
        let value = Abacus.Rounder.companion.round(number: 1.999, stepSize: 0.01, roundingMode: .towardsZero)
        XCTAssertEqual(value, 1.99)

//        let stateMachine = PerpTradingStateMachine(version: DataVersion.v4, maxSubaccountNumber: 1)
//        XCTAssertNotNil(stateMachine)
    }
}
