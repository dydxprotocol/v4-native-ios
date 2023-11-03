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

final class dydxTransferSubaccountWorker: BaseWorker {

    private static let balanceRetainAmount = 0.1

    override func start() {
        super.start()

        AbacusStateManager.shared.state.accountBalance(of: .usdc)
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
                self?.depositToSubaccount(amount: depositAmount,
                                          subaccount: subaccountNumber,
                                          walletState: state.walletState)
            }
            .store(in: &subscriptions)
    }

    private func depositToSubaccount(amount: Double, subaccount: Int, walletState: dydxWalletState) {
        CosmoJavascript.shared.depositToSubaccount(subaccount: subaccount, amount: amount) { result in
            let trackingData = [
                "amount": "\(amount)",
                "address": "\(String(describing: walletState.currentWallet?.cosmoAddress))"
            ]
            if let result = (result as? String)?.jsonDictionary,
               result["code"] as? Int == 0,
               result["hash"] != nil {
                Tracking.shared?.log(event: "SubaccountDeposit", data: trackingData)
            } else {
                Console.shared.log("Deposit to subaccount failed")
                Tracking.shared?.log(event: "SubaccountDeposit_Failed", data: trackingData)
            }
        }
    }
}
