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
    private let secondsInADay: TimeInterval = 24 * 60 * 60

    public func connectedWallet() {
        hasEverConnectedWallet = true
    }
    
    public func capturedScreenshotOrShare() {
        hasSharedOrScreenshottedSinceLastPrompt = true
    }
    
    public func portfolioCrossedPositiveFivePercent() {
        isPortfolioPositiveFivePercentSinceLastPrompt = true
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
    
    public func orderCreated() {
        numOrdersCreated += 1
    }
    
    private var numOrdersCreatedKey: String { "\(String(describing: className)).numOrdersCreatedKey" }
    private var uniqueDayAppOpensCountKey: String { "\(String(describing: className)).uniqueDayAppOpensCountKey" }
    private var lastAppOpenTimestampKey: String { "\(String(describing: className)).lastAppOpenTimestampKey" }
    private var lastPromptedTimestampKey: String { "\(String(describing: className)).lastPromptedTimestampKey" }
    private var hasEverConnectedWalletKey: String { "\(String(describing: className)).hasEverConnectedWallet" }
    private var isPortfolioPositiveFivePercentSinceLastPromptKey: String { "\(String(describing: className)).isPortfolioPositiveFivePercentSinceLastPromptKey" }
    private var hasSharedOrScreenshottedSinceLastPromptKey: String { "\(String(describing: className)).hasSharedOrScreenshottedKey" }
    private var hasBeenPromptedBeforeKey: String { "\(String(describing: className)).hasBeenPromptedBeforeKey" }
        
    private var numOrdersCreated: Int {
        get { UserDefaults.standard.integer(forKey: numOrdersCreatedKey) }
        set { UserDefaults.standard.set(newValue, forKey: numOrdersCreatedKey) }
    }
    
    /// the number of unique days the app was opened. If the app is opened Mon at 10am, Monday 10:30am, and Tuesday 10:30am, this count would be 2, counting the Mon at 10am and Tuesday 10:30am since they are more than 24hrs apart
    private var uniqueDayAppOpensCount: Int {
        get { UserDefaults.standard.integer(forKey: uniqueDayAppOpensCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: uniqueDayAppOpensCountKey) }
    }
    
    /// this value represents the last time the app was opened, but it should only be reset if it's current value is further than 24hrs away
    private var lastAppOpenTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: uniqueDayAppOpensCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: uniqueDayAppOpensCountKey) }
    }
    
    private var lastPromptedTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: lastPromptedTimestampKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastPromptedTimestampKey) }
    }

    private var isPortfolioPositiveFivePercentSinceLastPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: isPortfolioPositiveFivePercentSinceLastPromptKey) }
        set { UserDefaults.standard.set(newValue, forKey: isPortfolioPositiveFivePercentSinceLastPromptKey) }
    }
    
    private var hasSharedOrScreenshottedSinceLastPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: hasSharedOrScreenshottedSinceLastPromptKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSharedOrScreenshottedSinceLastPromptKey) }
    }
    
    private var hasEverConnectedWallet: Bool {
        get { UserDefaults.standard.bool(forKey: hasEverConnectedWalletKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasEverConnectedWalletKey) }
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
    ///    - C
    ///        - trader has opened the app 10 unique days or more since last prompt, resetting with each prompt
    ///        - trader has opened the app 3 unique days or more since last prompt **AND**
    ///            - trader portfolio is positive (up 5% or more in total)
    ///            - trader has shared a screenshot or the app
    ///            - trader has created 8 orders
    public final func tryPromptForRating() {
        let now = Date.now
        let shouldPrompt =
        hasSharedOrScreenshottedSinceLastPrompt ||
            (hasEverConnectedWallet && (uniqueDayAppOpensCount >= 8 || isPortfolioPositiveFivePercentSinceLastPrompt || numOrdersCreated > 10)) ||
            (!hasEverConnectedWallet && uniqueDayAppOpensCount >= 4)
        if shouldPrompt {
            promptForRating()
            reset()
        }
    }
    
    public func reset() {
        let now = Date()
        uniqueDayAppOpensCount = 0
        lastPromptedTimestamp = now.timeIntervalSince1970
        lastAppOpenTimestamp = now.timeIntervalSince1970
        hasSharedOrScreenshottedSinceLastPrompt = false
        isPortfolioPositiveFivePercentSinceLastPrompt = false
        numOrdersCreated = 0
    }
}
