//
//  dydxTransferReceiptViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/14/23.
//

import Abacus
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities
import Combine
import dydxFormatter

final class dydxTransferReceiptViewPresenter: dydxReceiptPresenter {
    override func start() {
        super.start()

        AbacusStateManager.shared.state.transferInput
            .sink { [weak self] (input: TransferInput) in
                self?.updateReceipt(transferInput: input)
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.selectedSubaccount
            .sink { [weak self] subaccount in
                if let buyingPower = subaccount?.buyingPower {
                    self?.updateBuyingPowerChange(buyingPower: buyingPower)
                }
                if let quoteBalance = subaccount?.quoteBalance {
                    self?.updateQuoteBalanceChange(quoteBalance: quoteBalance)
                }
            }
            .store(in: &subscriptions)
    }

    private func updateReceipt(transferInput: TransferInput?) {
        let transferSummary = transferInput?.summary
        slippageViewModel.title = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.SLIPPAGE")
        if let slippageVal = transferSummary?.slippage?.doubleValue,
            let slippage =  parser.asNumber(slippageVal / 100.0) {
            slippageViewModel.value = dydxFormatter.shared.percent(number: slippage, digits: 2)
        } else {
            slippageViewModel.value = nil
        }

        feeViewModel.feeType = "Gas"        // TODO
        if let gasFee = dydxFormatter.shared.dollar(number: parser.asNumber(transferSummary?.gasFee)) {
            feeViewModel.fee = .number(gasFee)
        } else {
            feeViewModel.fee = nil
        }

        bridgefeeViewModel.feeType = "Bridge"        // TODO
        if let bridgeFee = dydxFormatter.shared.dollar(number: parser.asNumber(transferSummary?.bridgeFee)) {
            bridgefeeViewModel.fee = .number(bridgeFee)
        } else {
            bridgefeeViewModel.fee = nil
        }

        exchangeRateViewModel.title = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.EXCHANGE_RATE")
        if let exchangeRate = transferSummary?.exchangeRate?.doubleValue,
           let type = transferInput?.type,
           let token = transferInput?.token,
           let symbol = transferInput?.resources?.tokenResources?[token]?.symbol {
            let value: String?
            switch type {
            case .deposit:
                if let converted = dydxFormatter.shared.raw(number: parser.asNumber(exchangeRate), size: nil) {
                    value = "1 \(symbol) = \(converted) USDC"
                } else {
                    value = nil
                }
            case .withdrawal:
                if exchangeRate > 0, let converted = dydxFormatter.shared.raw(number: parser.asNumber(1.0 / exchangeRate), size: nil) {
                    value = "\(converted) USDC = 1 \(symbol)"
                } else {
                    value = nil
                }
            default:
                value = nil
                break
            }
            exchangeRateViewModel.value = value
        } else {
            exchangeRateViewModel.value = nil
        }

        exchangeReceivedViewModel.title = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.EXCHANGE_RECEIVED")
        if let exchangeRate = transferSummary?.exchangeRate?.doubleValue,
           let type = transferInput?.type,
           let token = transferInput?.token,
           let symbol = transferInput?.resources?.tokenResources?[token]?.symbol {
            let value: String?
            switch type {
            case .deposit:
                if let usdcSize = parser.asDecimal(transferInput?.size?.usdcSize)?.doubleValue,
                   let converted = dydxFormatter.shared.raw(number: parser.asNumber(usdcSize), size: nil) {
                    value = "\(converted) USDC"
                } else {
                    value = nil
                }
            case .withdrawal:
                if let toAmount = transferSummary?.toAmount?.doubleValue,
                   let decimals = transferInput?.resources?.tokenResources?[token]?.decimals?.doubleValue {
                    let size = toAmount / pow(10, decimals)
                    if let converted = dydxFormatter.shared.raw(number: parser.asNumber(size), size: "0.0001") {
                        value = "\(converted) \(symbol)"
                    } else {
                        value = nil
                    }
                } else {
                    if let usdcSize = parser.asDecimal(transferInput?.size?.usdcSize)?.doubleValue,
                       exchangeRate > 0, let converted = dydxFormatter.shared.raw(number: parser.asNumber(usdcSize * exchangeRate), size: nil) {
                        value = "\(converted) \(symbol)"
                    } else {
                        value = nil
                    }
                }
            default:
                value = nil
                break
            }
            exchangeReceivedViewModel.value = value
        } else {
            exchangeReceivedViewModel.value = nil
        }

        transferDurationViewModel.title = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.ESTIMATED_TIME")
        if let estimatedRouteDuration = transferSummary?.estimatedRouteDuration?.doubleValue,
           let minutes = parser.asString(Int(ceil(estimatedRouteDuration / 60))) {
            let minutesLocalized = DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.X_MINUTES", params: ["X": minutes])
            transferDurationViewModel.value = minutesLocalized
        } else {
            transferDurationViewModel.value = nil
        }
    }
}
