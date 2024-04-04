//
//  dydxPointsRatingTests.swift
//  dydxStateManagerTests
//
//  Created by Michael Maguire on 2/29/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import XCTest
@testable import dydxStateManager

private class TestPointsRating: dydxPointsRating {
    override var secondsInADay: TimeInterval { 0.05 }

    var promptWasReached: Bool = false

    override func promptForRating() {
        guard !shouldStopPreprompting else { return }
        promptWasReached = true
        reset()
    }
}

final class dydxPointsRatingTests: XCTestCase {

    private var testStartMillis: TimeInterval!
    private var testPointRating: TestPointsRating!

    override func setUpWithError() throws {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        testPointRating = TestPointsRating()
        testStartMillis = Date.now.timeIntervalSince1970
    }

    func testSingleAppLaunch() throws {
        testPointRating.launchedApp()
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, false)
        XCTAssertLessThan(testStartMillis, testPointRating.lastAppOpenTimestamp)
        XCTAssertLessThan(testPointRating.lastAppOpenTimestamp, Date.now.timeIntervalSince1970)
    }

    func testMultipleAppLaunches() {
        for _ in 1..<4 {
            Thread.sleep(forTimeInterval: testPointRating.secondsInADay)
            testPointRating.launchedApp()
        }
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, false)

        Thread.sleep(forTimeInterval: testPointRating.secondsInADay)
        testPointRating.launchedApp()
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, true)

    }

    func testConnectedWalletAndSingleAppLaunch() {
        testPointRating.launchedApp()
        testPointRating.connectedWallet()
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, false)
    }

    func testConnectedWalletAndMultipleAppLaunchesAndDisablePreprompting() {
        testPointRating.connectedWallet()
        for i in 1...8 {
            Thread.sleep(forTimeInterval: testPointRating.secondsInADay)
            testPointRating.launchedApp()
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, i == 8 ? true : false)
        }
        testPointRating.promptWasReached = false

        for i in 1...8 {
            Thread.sleep(forTimeInterval: testPointRating.secondsInADay)
            testPointRating.launchedApp()
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, i == 8 ? true : false)
        }
        testPointRating.promptWasReached = false

        testPointRating.disablePreprompting()
        for i in 1...8 {
            Thread.sleep(forTimeInterval: testPointRating.secondsInADay)
            testPointRating.launchedApp()
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, false)
        }
    }

    func testConnectedWalletAndScreenshotOrCapture() {
        testPointRating.capturedScreenshotOrShare()
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, true)
    }

    func testConnectedWalletAndOrders() {
        testPointRating.connectedWallet()
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, false)

        for i in 1...8 {
            testPointRating.orderCreated(orderId: "\(i)", orderCreatedTimestampMillis: testPointRating.lastPromptedTimestamp + Double(i))
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, i == 8 ? true : false)
        }
        testPointRating.promptWasReached = false

        for i in 1...8 {
            testPointRating.orderCreated(orderId: "\(i)\(i)", orderCreatedTimestampMillis: testPointRating.lastPromptedTimestamp * 1000 + Double(i))
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, i == 8 ? true : false)
        }
    }

    func testConnectedWalletAndTransfers() {
        testPointRating.connectedWallet()
        testPointRating.tryPromptForRating()
        XCTAssertEqual(testPointRating.promptWasReached, false)

        for i in 1...2 {
            testPointRating.transferCreated(transferId: "\(i)", transferCreatedTimestampMillis: testPointRating.lastPromptedTimestamp * 1000 + Double(i))
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, i == 2 ? true : false)
        }
        testPointRating.promptWasReached = false

        for i in 1...2 {
            testPointRating.transferCreated(transferId: "\(i)\(i)", transferCreatedTimestampMillis: testPointRating.lastPromptedTimestamp * 1000 + Double(i))
            testPointRating.tryPromptForRating()
            XCTAssertEqual(testPointRating.promptWasReached, i == 2 ? true : false)
        }
    }

}
