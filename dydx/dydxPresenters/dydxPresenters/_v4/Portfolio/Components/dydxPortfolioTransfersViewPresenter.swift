//
//  dydxHistoricalTransfersViewPresenter.swift
//  dydxUI
//
//  Created by Michael Maguire on 9/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxStateManager
import Abacus
import PlatformRouting
import dydxViews

private protocol dydxPortfolioTransfersViewPresenter: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioTransfersViewModel? { get }
}

class dydxHistoricalTransfersViewPresenter: HostedViewPresenter<dydxPortfolioTransfersViewModel>, dydxPortfolioTransfersViewPresenter {
    init(viewModel: dydxPortfolioTransfersViewModel) {
        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_TRANSFERS")
                } else {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_TRANSFERS_LOG_IN")
                }
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.transfers
            .sink {[weak self] transfers in
                self?.viewModel?.items = transfers.map(dydxHistoricalTransfersViewPresenter.createViewModelItem(transferInstance:)).filterNils()
            }
            .store(in: &subscriptions)
    }

    private static func createViewModelItem(transferInstance: SubaccountTransfer) -> TransferInstanceViewModel? {
        let type: TransferInstanceViewModel.TransferType
        switch transferInstance.type {
        case .deposit: type = .deposit
        case .withdraw: type = .withdrawal
        case .transferOut: type = .transferOut
        case .transferIn: type = .transferIn
        default: return nil
        }

        if let fromAddress = transferInstance.fromAddress,
            let toAddress = transferInstance.toAddress,
            let amount = transferInstance.amount?.doubleValue {
            return .init(date: Date(milliseconds: transferInstance.updatedAtMilliseconds),
                         type: type,
                         amount: amount,
                         fromAddress: fromAddress,
                         toAddress: toAddress)
        }
        return nil
    }
}
