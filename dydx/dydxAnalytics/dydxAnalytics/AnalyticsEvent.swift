//
//  AnalyticsEvent.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/03/2024.
//

import Foundation
import PlatformParticles
import Utilities
import FirebaseAnalytics

//
// Events defined in the v4-web repo.  Ideally, we should keep this in-sync with v4-web
//
// TODO: deprecate and replace with AnalyticsEventV2
public enum AnalyticsEvent: String {
    // App
    case networkStatus = "NetworkStatus"

    // Navigation
    case navigatePage = "NavigatePage"
    case navigateDialog = "NavigateDialog"
    case navigateDialogClose = "NavigateDialogClose"
    case navigateExternal = "NavigateExternal"

    // Wallet
    case connectWallet = "ConnectWallet"
    case disconnectWallet = "DisconnectWallet"

    // Onboarding
    case onboardingStepChanged = "OnboardingStepChanged"
    case onboardingAccountDerived = "OnboardingAccountDerived"
    case onboardingWalletIsNonDeterministic = "OnboardingWalletIsNonDeterministic"

    // Transfers
    case transferFaucet = "TransferFaucet"
    case transferFaucetConfirmed = "TransferFaucetConfirmed"
    case transferDeposit = "TransferDeposit"
    case transferWithdraw = "TransferWithdraw"

    // Trading
    case tradeOrderTypeSelected = "TradeOrderTypeSelected"
    case tradePlaceOrder = "TradePlaceOrder"
    case tradePlaceOrderConfirmed = "TradePlaceOrderConfirmed"
    case tradeCancelOrder = "TradeCancelOrder"
    case tradeCancelOrderConfirmed = "TradeCancelOrderConfirmed"

    // Notification
    case notificationAction = "NotificationAction"
}

public extension AnalyticsEventV2 {
    enum OnboardingStep: String {
        case chooseWallet = "ChooseWallet"
        case keyDerivation = "KeyDerivation"
        case acknowledgeTerms = "AcknowledgeTerms"
        case depositFunds = "DepositFunds"
    }
}

public extension AnalyticsEventV2 {
    enum OnboardingState: String {
        case disconnected = "Disconnected"
        case walletConnected = "WalletConnected"
        case accountConnected = "AccountConnected"
    }
}

public enum AnalyticsEventV2 {
    public struct AppStart: TrackableEvent {
        public var name: String { "AppStart" }
        public var customParameters: [String: Any] { [:] }

        public init() {}
    }

    public struct NavigatePage: TrackableEvent {
        public let screen: ScreenIdentifiable

        public var name: String { "NavigatePage" }
        public var customParameters: [String: Any] {[
            "mobile_path": screen.mobilePath,
            "path": screen.correspondingWebPath as Any,
            // for firebase auto-generated dashboard(s)
            "\(AnalyticsParameterScreenClass)": screen.screenClass,
            "\(AnalyticsParameterScreenName)": screen.mobilePath
        ]}

        public init(screen: ScreenIdentifiable) {
            self.screen = screen
        }
    }

    public struct DeepLinkHandled: TrackableEvent {
        let url: String
        let succeeded: Bool

        public var name: String { "DeeplinkHandled" }
        public var customParameters: [String: Any] {[
            "url": url,
            "succeeded": succeeded
        ]}

        public init(url: String, succeeded: Bool) {
            self.url = url
            self.succeeded = succeeded
        }
    }

    public struct NotificationPermissionsChanged: TrackableEvent {
        let isAuthorized: Bool

        public var name: String { "NotificationPermissionsChanged" }
        public var customParameters: [String: Any] {[
            "is_authorized": isAuthorized
        ]}

        public init(isAuthorized: Bool) {
            self.isAuthorized = isAuthorized
        }
    }

    public struct OnboardingStepChanged: TrackableEvent {
        let step: OnboardingStep
        let state: OnboardingState

        public var name: String { "OnboardingStepChanged" }
        public var customParameters: [String: Any] {[
            "step": step.rawValue,
            "state": state.rawValue
        ]}

        public init(step: OnboardingStep, state: OnboardingState) {
            self.step = step
            self.state = state
        }
    }
}

public extension TrackingProtocol {
    func log(event: TrackableEvent) {
        if let event = event as? AnalyticsEventV2.NavigatePage {
            log(event: AnalyticsEventScreenView, data: event.customParameters)
        }
        log(event: event.name, data: event.customParameters)
        #if DEBUG
        Console.shared.log(event.description)
        #endif
    }
}
