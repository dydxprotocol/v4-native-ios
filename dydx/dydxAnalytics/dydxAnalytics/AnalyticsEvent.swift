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

public extension AnalyticsEventV2 {
    enum VaultAnalyticsInputType: String {
        case deposit = "DEPOSIT"
        case withdraw = "WITHDRAW"
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
            // see comment below for screen_view
            "screen_class": screen.screenClass,
            "screen_name": screen.mobilePath
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

    public struct VaultFormPreviewStep: TrackableEvent {
        let type: VaultAnalyticsInputType
        let amount: Double

        public var name: String { "VaultFormPreviewStep" }
        public var customParameters: [String: Any] {[
            "amount": amount,
            "operation": type.rawValue
        ]}

        public init(amount: Double, type: VaultAnalyticsInputType) {
            self.amount = amount
            self.type = type
        }
    }

    public struct AttemptVaultOperation: TrackableEvent {
        let type: VaultAnalyticsInputType
        let amount: Double?
        let slippage: Double?

        public var name: String { "AttemptVaultOperation" }
        public var customParameters: [String: Any] {
            var dict: [String: Any] = [
                "operation": type.rawValue
            ]
            if let amount {
                dict["amount"] = amount
            }
            if let slippage {
                dict["slippage"] = slippage
            }
            return dict
        }

        public init(type: VaultAnalyticsInputType, amount: Double?, slippage: Double?) {
            self.type = type
            self.amount = amount
            self.slippage = slippage
        }
    }

    public struct SuccessfulVaultOperation: TrackableEvent {
        let type: VaultAnalyticsInputType
        let amount: Double
        let amountDiff: Double

        public var name: String { "SuccessfulVaultOperation" }
        public var customParameters: [String: Any] {[
            "operation": type.rawValue,
            "amount": amount,
            "amountDiff": amountDiff
        ]}

        public init(type: VaultAnalyticsInputType, amount: Double, amountDiff: Double) {
            self.type = type
            self.amount = amount
            self.amountDiff = amountDiff
        }
    }

    public struct VaultOperationProtocolError: TrackableEvent {
        let type: VaultAnalyticsInputType

        public var name: String { "VaultOperationProtocolError" }
        public var customParameters: [String: Any] {[
            "operation": type.rawValue
        ]}

        public init(type: VaultAnalyticsInputType) {
            self.type = type
        }
    }

    public struct RoutingEvent: TrackableEvent {
        let fromPath: String?
        let toPath: String
        let fromQuery: String?
        let toQuery: String?

        public var name: String { "RoutingEvent" }
        public var customParameters: [String: Any] {[
            "fromPath": fromPath ?? "nil",
            "toPath": toPath,
            "fromQuery": fromQuery ?? "nil",
            "toQuery": toQuery ?? "nil"
        ]}

        public init(fromPath: String? = nil, toPath: String, fromQuery: String? = nil, toQuery: String? = nil) {
            self.fromPath = fromPath
            self.toPath = toPath
            self.fromQuery = fromQuery
            self.toQuery = toQuery
        }
    }

    public struct ModeSelectorEvent: TrackableEvent {
        let fromMode: String
        let toMode: String

        public var name: String { "ModeSelectorEvent" }
        public var customParameters: [String: Any] {[
            "from": fromMode,
            "to": toMode
        ]}

        public init(fromMode: String, toMode: String) {
            self.fromMode = fromMode
            self.toMode = toMode
        }
    }
}

public extension TrackingProtocol {
    func log(event: TrackableEvent) {
        if let event = event as? AnalyticsEventV2.NavigatePage {
            // for firebase auto-generated dashboard(s). Cannot import firebase analytics to use the event `AnalyticsEventScreenView` here because
            // Firebase's binary distributions, including Firebase Analytics, are build as static xcframeworks and do not support being linked into dynamic frameworks
            // https://github.com/firebase/firebase-ios-sdk/issues/12618#issuecomment-2016507842
            log(event: "screen_view", data: event.customParameters)
        }
        log(event: event.name, data: event.customParameters)
        #if DEBUG
        Console.shared.log(event.description)
        #endif
    }
}
