//
//  AnalyticsEvent.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/03/2024.
//

import Foundation

//
// Events defined in the v4-web repo.  Ideally, we should keep this in-sync with v4-web
//
enum AnalyticsEvent: String {
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
