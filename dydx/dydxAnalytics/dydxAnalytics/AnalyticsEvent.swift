//
//  AnalyticsEvent.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/03/2024.
//

import Foundation
import PlatformParticles
import Utilities
//
// Events defined in the v4-web repo.  Ideally, we should keep this in-sync with v4-web
//
public enum AnalyticsEvent: String {
    // App
    case appStart = "AppStart"
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
    // probably move this to like a dydxRouter, next to where `routing_swift.json` currently lives
    enum Page {
        case markets
        case market(market: String)
        case trade(market: String)
        case addSlTp

        /// a path that uniquely identifies the mobile screen
        var mobilePath: String {
            switch self {
            case .markets:
                return "/markets"
            case .trade(let market):
                return "/trade/\(market)"
            case .market(let market):
                return "/market/\(market)"
            case .addSlTp:
                return "/trade/take_profit_stop_loss"
            }
        }

        /// the web-equivalent web page (if there is a good match)
        var correspondingWebPath: String? {
            switch self {
            case .addSlTp:
                return nil // displayed as a modal on web
            case .market(let market):
                // web does not have the /market/ETH-USD path and routes back to `/trade/ETH-USD`
                return Page.trade(market: market).correspondingWebPath
            default:
                return mobilePath
            }
        }
    }
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
    case navigatePage(page: Page)
    case navigateDialog(page: Page)
    case navigateDialogClose(page: Page)
    case onboardingStepChanged(step: OnboardingStep, state: OnboardingState)

    public var name: String {
        switch self {
        case .navigatePage:
            return "NavigatePage"
        case .navigateDialog:
            return "NavigateDialog"
        case .navigateDialogClose:
            return "NavigateDialogClose"
        case .appStart:
            return "AppStart"
        case .onboardingStepChanged:
            return "OnboardingStepChanged"
        }
    }

    public var customParameters: [String: Any] {
        switch self {
        case .appStart:
            return [:]
        case .navigatePage(let page), .navigateDialog(let page), .navigateDialogClose(let page):
            return [
                "mobile_path": page.mobilePath,
                "path": page.correspondingWebPath as Any
            ]
        case .onboardingStepChanged(let step, let state):
            return [
                "step": step.rawValue,
                "state": state.rawValue
            ]
        }
    }
}

public extension TrackingProtocol {
    /// convenience wrapper of log(trackableEvent:)
    func log(event: AnalyticsEventV2) {
        Tracking.shared?.log(trackableEvent: event)
    }
}
