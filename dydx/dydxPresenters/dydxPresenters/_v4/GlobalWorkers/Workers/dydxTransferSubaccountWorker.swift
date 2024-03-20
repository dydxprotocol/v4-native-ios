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

    private static let balanceRetainAmount = 0.25

    override func start() {
        super.start()

        AbacusStateManager.shared.state.accountBalance(of: AbacusStateManager.shared.environment?.usdcTokenInfo?.denom)
            .filter { value in
                (value ?? 0) > dydxTransferSubaccountWorker.balanceRetainAmount
            }
            .withLatestFrom(
                Publishers.CombineLatest(
                    AbacusStateManager.shared.state.walletState,
                    AbacusStateManager.shared.state.selectedSubaccount
                )
                .map { (walletState: $0, subaccount: $1) }
                .eraseToAnyPublisher()
            )
            .sink { [weak self] balance, state in
                let subaccountNumber: Int
                if let subaccount = state.subaccount {
                    subaccountNumber = Int(subaccount.subaccountNumber)
                } else {
                    subaccountNumber = 0
                }
                let depositAmount = (balance ?? 0) - dydxTransferSubaccountWorker.balanceRetainAmount
                let amountString = dydxFormatter.shared.raw(number: NSNumber(value: depositAmount),
                                                            digits: dydxTokenConstants.usdcTokenDecimal)
                if let amountString = amountString {
                    self?.depositToSubaccount(amount: amountString,
                                              subaccount: subaccountNumber,
                                              walletState: state.walletState)
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
