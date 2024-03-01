//
//  PointedRating.swift
//  Utilities
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import StoreKit

/// See notion https://www.notion.so/dydx/App-Store-Review-Spec-226c9031b0c746e488e02c7eeb1ab46f?pvs=4
open class PointsRating: NSObject, RatingProtocol {
    
    var secondsInADay: TimeInterval { 24 * 60 * 60 }

    public func connectedWallet() {
        hasEverConnectedWallet = true
    }
    
    public func capturedScreenshotOrShare() {
        hasSharedOrScreenshottedSinceLastPrompt = true
    }
    
    public func launchedApp() {
        let now = Date.now
        if lastPromptedTimestamp == 0 {
            //set this to reset the timer between prompts on initial app launch
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lastPromptedTimestampKey)
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
            ordersCreatedSinceLastPrompt.insert(transferId)
        }
    }
    
    var transfersCreatedSinceLastPromptKey: String { "\(String(describing: className)).transfersCreatedSinceLastPromptKey" }
    var ordersCreatedSinceLastPromptKey: String { "\(String(describing: className)).ordersCreatedSinceLastPromptKey" }
    var uniqueDayAppOpensCountKey: String { "\(String(describing: className)).uniqueDayAppOpensCountKey" }
    var lastAppOpenTimestampKey: String { "\(String(describing: className)).lastAppOpenTimestampKey" }
    var lastPromptedTimestampKey: String { "\(String(describing: className)).lastPromptedTimestampKey" }
    var hasEverConnectedWalletKey: String { "\(String(describing: className)).hasEverConnectedWallet" }
    
    var hasSharedOrScreenshottedSinceLastPromptKey: String { "\(String(describing: className)).hasSharedOrScreenshottedKey" }
    var shouldStopPromptingKey: String { "\(String(describing: className)).shouldStopPromptingKey" }

    /// this is maintained as a set for easier order count de-duping
    var ordersCreatedSinceLastPrompt: Set<String> {
        get { Set(UserDefaults.standard.array(forKey: ordersCreatedSinceLastPromptKey) as? [String] ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: ordersCreatedSinceLastPromptKey) }
    }
    
    /// this is maintained as a set for easier order count de-duping
    var transfersCreatedSinceLastPrompt: Set<String> {
        get { Set(UserDefaults.standard.array(forKey: transfersCreatedSinceLastPromptKey) as? [String] ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: transfersCreatedSinceLastPromptKey) }
    }
    
    /// the number of unique days the app was opened. If the app is opened Mon at 10am, Monday 10:30am, and Tuesday 10:30am, this count would be 2, counting the Mon at 10am and Tuesday 10:30am since they are more than 24hrs apart
    var uniqueDayAppOpensCount: Int {
        get { UserDefaults.standard.integer(forKey: uniqueDayAppOpensCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: uniqueDayAppOpensCountKey) }
    }
    
    /// this value represents the last time the app was opened, but it should only be reset if it's current value is further than 24hrs away
    var lastAppOpenTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: lastAppOpenTimestampKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastAppOpenTimestampKey) }
    }
    
    var lastPromptedTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: lastPromptedTimestampKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastPromptedTimestampKey) }
    }
    
    var hasSharedOrScreenshottedSinceLastPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: hasSharedOrScreenshottedSinceLastPromptKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSharedOrScreenshottedSinceLastPromptKey) }
    }
    
    var hasEverConnectedWallet: Bool {
        get { UserDefaults.standard.bool(forKey: hasEverConnectedWalletKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasEverConnectedWalletKey) }
    }
    
    /// whether the user has continued to app store review after pre-prompt
    public var shouldStopPrompting: Bool {
        get { UserDefaults.standard.bool(forKey: shouldStopPromptingKey) }
        set { UserDefaults.standard.set(newValue, forKey: shouldStopPromptingKey) }
    }
    
    open func promptForRating() {
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
    ///            - ~~trader portfolio is positive (up 5% or more in total)~~ this was not work the effort
    ///            - trader has shared a screenshot or the app
    ///            - trader has created 8 or more orders
    open func tryPromptForRating() {
        Console.shared.log("mmm transfersCreatedSinceLastPrompt: \(transfersCreatedSinceLastPrompt.count)")
        Console.shared.log("mmm ordersCreatedSinceLastPrompt: \(ordersCreatedSinceLastPrompt.count)")
        Console.shared.log("mmm uniqueDayAppOpensCount: \(uniqueDayAppOpensCount)")
        Console.shared.log("mmm lastAppOpenTimestamp: \(lastAppOpenTimestamp)")
        Console.shared.log("mmm lastPromptedTimestamp: \(lastPromptedTimestamp)")
        Console.shared.log("mmm hasEverConnectedWallet: \(hasEverConnectedWallet)")
        Console.shared.log("mmm hasSharedOrScreenshottedSinceLastPrompt: \(hasSharedOrScreenshottedSinceLastPrompt)")
        Console.shared.log("mmm shouldStopPrompting: \(shouldStopPrompting)")
        
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
