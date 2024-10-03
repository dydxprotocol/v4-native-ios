//
//  dydxV4UITests.swift
//  dydxV4UITests
//
//  Created by Rui Huang on 1/16/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import XCTest
import PercyXcui

final class dydxV4UITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()

        // take screenshot
        let appPercy = AppPercy()

        do {
            try appPercy.screenshot(name: "First Screenshot")
        } catch {
            NSLog("App percy screenshot failed")
        }
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
