//
//  dydxTransferSubaccountWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 7/25/23.
//

import Foundation
import Utilities
import dydxStateManager
import Combine
import Abacus
import ParticlesKit
import dydxFormatter

final class dydxTransferSubaccountWorker: BaseWorker {

    private static let balanceRetainAmount = 0.5

    override func start() {
        super.start()

        AbacusStateManager.shared.state.accountBalance(of: AbacusStateManager.shared.environment?.usdcTokenInfo?.denom)
            .withLatestFrom(
                AbacusStateManager.shared.state.walletState
            )
            .sink { [weak self] balance, walletState in
                guard let balance, balance > dydxTransferSubaccountWorker.balanceRetainAmount else { return }
                let depositAmount = balance - dydxTransferSubaccountWorker.balanceRetainAmount
                let amountString = dydxFormatter.shared.decimalLocaleAgnostic(number: NSNumber(value: depositAmount),
                                                                              digits: dydxTokenConstants.usdcTokenDecimal)
                if let amountString = amountString {
                    self?.depositToSubaccount(amount: amountString,
                                              subaccount: AbacusStateManager.shared.selectedSubaccountNumber,
                                              walletState: walletState)
                } else {
                    Console.shared.log("dydxTransferSubaccountWorker: Invalid amount")
                }
            }
            .store(in: &subscriptions)
    }

    private func depositToSubaccount(amount: String, subaccount: Int, walletState: dydxWalletState) {
        CosmoJavascript.shared.depositToSubaccount(subaccount: subaccount, amount: amount) { result in
            var trackingData = [
                "amount": "\(amount)",
                "address": "\(String(describing: walletState.currentWallet?.cosmoAddress))"
            ]
            if let result = (result as? String)?.jsonDictionary,
               result["code"] as? Int == 0,
               result["hash"] != nil {
                Tracking.shared?.log(event: "SubaccountDeposit", data: trackingData)
            } else {
                Console.shared.log("Deposit to subaccount failed")
                if let resultString = result as? String {
                    trackingData["error"] = resultString
                }
                Tracking.shared?.log(event: "SubaccountDeposit_Failed", data: trackingData)
            }
        }
    }
}
