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

public enum AnalyticsEventV2: TrackableEvent {
    case appStart
    case navigatePage(screen: ScreenIdentifiable)
    case deepLinkHandled(url: String, succeeded: Bool)
    case notificationPermissionsChanged(isAuthorized: Bool)
    case onboardingStepChanged(step: OnboardingStep, state: OnboardingState)

    public var name: String {
        switch self {
        case .navigatePage:
            return "NavigatePage"
        case .deepLinkHandled:
            return "DeeplinkHandled"
        case .appStart:
            return "AppStart"
        case .onboardingStepChanged:
            return "OnboardingStepChanged"
        case .notificationPermissionsChanged:
            return "NotificationPermissionsChanged"
        }
    }

    public var customParameters: [String: Any] {
        switch self {
        case .appStart:
            return [:]
        case .navigatePage(let screen):
            return [
                "mobile_path": screen.mobilePath,
                "path": screen.correspondingWebPath as Any,
                // for firebase auto-generated dashboard(s)
                "\(AnalyticsParameterScreenClass)": screen.screenClass,
                "\(AnalyticsParameterScreenName)": screen.mobilePath
            ]
        case .deepLinkHandled(let url, let succeeded):
            return [
                "successfully_handled": succeeded,
                "url": url
            ]
        case .onboardingStepChanged(let step, let state):
            return [
                "step": step.rawValue,
                "state": state.rawValue
            ]
        case .notificationPermissionsChanged(let isAuthorized):
            return [
                "is_authorized": isAuthorized
            ]
        }
    }
}

public extension TrackingProtocol {
    func log(event: AnalyticsEventV2) {
        log(event: event.name, data: event.customParameters)
        switch event {
        case .navigatePage:
            // for firebase auto-generated dashboard(s)
            log(event: AnalyticsEventScreenView, data: event.customParameters)
        default:
            break
        }
    }
}
