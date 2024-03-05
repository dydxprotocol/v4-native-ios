//
//  PointedRating.swift
//  Utilities
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import StoreKit
import Utilities
import dydxFormatter
import RoutingKit

/// See notion https://www.notion.so/dydx/App-Store-Review-Spec-226c9031b0c746e488e02c7eeb1ab46f?pvs=4
open class dydxPointsRating: NSObject, dydxRatingProtocol {

    private enum Key: String {
        case transfersCreatedSinceLastPrompt
        case ordersCreatedSinceLastPrompt
        case uniqueDayAppOpensCount
        case lastAppOpenTimestamp
        case lastPromptedTimestamp
        case hasEverConnectedWallet
        case hasSharedOrScreenshottedSinceLastPrompt
        case shouldStopPrompting

        var storeKey: String { "\(String(describing: dydxPointsRating.self)).\(self.rawValue)Key" }
    }

    var secondsInADay: TimeInterval { 24 * 60 * 60 }

    public var stateData: [String: Any] {[
        "transfers_created_count": transfersCreatedSinceLastPrompt.count,
        "orders_created_count": ordersCreatedSinceLastPrompt.count,
        "unique_day_app_opens_count": uniqueDayAppOpensCount,
        "last_app_open_timestamp": lastAppOpenTimestamp,
        "last_prompted_timestamp": lastPromptedTimestamp,
        "has_ever_connected_wallet": hasEverConnectedWallet,
        "has_shared_or_screenshotted": hasSharedOrScreenshottedSinceLastPrompt,
        "should_stop_prompting": shouldStopPrompting
    ]}

    public func connectedWallet() {
        hasEverConnectedWallet = true
    }

    public func capturedScreenshotOrShare() {
        hasSharedOrScreenshottedSinceLastPrompt = true
    }

    public func launchedApp() {
        let now = Date.now
        if lastPromptedTimestamp == 0 {
            // set this to reset the timer between prompts on initial app launch
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: Key.lastPromptedTimestamp.storeKey)
        }
        if now.timeIntervalSince1970 - lastAppOpenTimestamp > secondsInADay {
            uniqueDayAppOpensCount += 1
            lastAppOpenTimestamp = now.timeIntervalSince1970
        }
    }

    public func orderCreated(orderId: String, orderCreatedTimestampMillis: TimeInterval) {
        if orderCreatedTimestampMillis / 1000 > lastPromptedTimestamp {
            ordersCreatedSinceLastPrompt.insert(orderId)
        }
    }

    public func transferCreated(transferId: String, transferCreatedTimestampMillis: TimeInterval) {
        if transferCreatedTimestampMillis / 1000 > lastPromptedTimestamp {
            transfersCreatedSinceLastPrompt.insert(transferId)
        }
    }

    public func disablePrompting() {
        shouldStopPrompting = true
    }

    /// this is maintained as a set for easier order count de-duping
    var ordersCreatedSinceLastPrompt: Set<String> {
        get { Set(UserDefaults.standard.array(forKey: Key.ordersCreatedSinceLastPrompt.storeKey) as? [String] ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: Key.ordersCreatedSinceLastPrompt.storeKey) }
    }

    /// this is maintained as a set for easier order count de-duping
    var transfersCreatedSinceLastPrompt: Set<String> {
        get { Set(UserDefaults.standard.array(forKey: Key.transfersCreatedSinceLastPrompt.storeKey) as? [String] ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: Key.transfersCreatedSinceLastPrompt.storeKey) }
    }

    /// the number of unique days the app was opened. If the app is opened Mon at 10am, Monday 10:30am, and Tuesday 10:30am, this count would be 2, counting the Mon at 10am and Tuesday 10:30am since they are more than 24hrs apart
    var uniqueDayAppOpensCount: Int {
        get { UserDefaults.standard.integer(forKey: Key.uniqueDayAppOpensCount.storeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Key.uniqueDayAppOpensCount.storeKey) }
    }

    /// this value represents the last time the app was opened, but it should only be reset if it's current value is further than 24hrs away
    var lastAppOpenTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: Key.lastAppOpenTimestamp.storeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Key.lastAppOpenTimestamp.storeKey) }
    }

    var lastPromptedTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: Key.lastPromptedTimestamp.storeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Key.lastPromptedTimestamp.storeKey) }
    }

    var hasSharedOrScreenshottedSinceLastPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: Key.hasSharedOrScreenshottedSinceLastPrompt.storeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Key.hasSharedOrScreenshottedSinceLastPrompt.storeKey) }
    }

    var hasEverConnectedWallet: Bool {
        get { UserDefaults.standard.bool(forKey: Key.hasEverConnectedWallet.storeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Key.hasEverConnectedWallet.storeKey) }
    }

    /// whether the user has continued to app store review after pre-prompt
    var shouldStopPrompting: Bool {
        get { UserDefaults.standard.bool(forKey: Key.shouldStopPrompting.storeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Key.shouldStopPrompting.storeKey) }
    }

    public func promptForRating() {
        // feature flag in case the prompt has issues
        if !dydxBoolFeatureFlag.enable_app_rating.isEnabled { return }
        Tracking.shared?.log(event: "PrepromptedForRating", data: stateData)
        Router.shared?.navigate(to: RoutingRequest(path: "/rate_app"), animated: true, completion: nil)

        #if DEBUG
            Console.shared.log("mock prompt for rating")
        #else
            SKStoreReviewController.requestReview()
        #endif
    }

    ///    See discussion below:
    ///
    ///    There are a few trader categories to consider
    ///
    ///    - A - no wallet connected
    ///    - B - wallet connected, no deposits
    ///    - C - wallet connected, deposit
    ///
    ///    For each trader category, here are the scenarios we want to set `shouldPromptForAppReview` to true. Note only one scenario has to occur for the user group.
    ///
    ///    - A or B
    ///        - trader has opened the app 4 unique days or more, resetting with each prompt
    ///        - trader has shared a screenshot or the app
    ///    - C
    ///        - trader has opened the app 8 unique days or more since last prompt, resetting with each prompt
    ///        - trader has opened the app 3 unique days or more since last prompt **AND** one of the below
    ///            - trader has shared a screenshot or the app
    ///            - trader has created 8 or more orders
    open func tryPromptForRating() {
        guard !shouldStopPrompting else { return }
        let shouldPrompt =
            hasSharedOrScreenshottedSinceLastPrompt
            || (hasEverConnectedWallet && (uniqueDayAppOpensCount >= 8 || transfersCreatedSinceLastPrompt.count >= 2 || ordersCreatedSinceLastPrompt.count >= 8))
            || (!hasEverConnectedWallet && uniqueDayAppOpensCount >= 4)
        if shouldPrompt {
            promptForRating()
            reset()
        }
    }

    func reset() {
        let now = Date()
        uniqueDayAppOpensCount = 0
        lastPromptedTimestamp = now.timeIntervalSince1970
        lastAppOpenTimestamp = now.timeIntervalSince1970
        hasSharedOrScreenshottedSinceLastPrompt = false
        ordersCreatedSinceLastPrompt = []
        transfersCreatedSinceLastPrompt = []
    }
}
