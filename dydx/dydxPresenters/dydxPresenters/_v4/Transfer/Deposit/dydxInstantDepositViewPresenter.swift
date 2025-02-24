//
//  dydxInstantDepositViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 21/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter
import dydxStateManager
import Combine
import Abacus

protocol dydxInstantDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxInstantDepositViewModel? { get }
}

class dydxInstantDepositViewPresenter: HostedViewPresenter<dydxInstantDepositViewModel>, dydxInstantDepositViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxInstantDepositViewModel.previewValue
    }

    override func start() {
        super.start()

        guard let transferTokenDetails = TransferTokenDetails.shared else {
            return
        }

        Publishers
            .CombineLatest(
                transferTokenDetails.$defaultToken,
                transferTokenDetails.$selectedToken)
            .sink { [weak self] defaultToken, selectedToken in
                self?.updateInputToken(token: selectedToken ?? defaultToken)
            }
            .store(in: &subscriptions)
    }

    private func updateInputToken(token: TransferTokenInfo?) {
        let input = dydxInstantDepositInputModel()
        input.maxAmount = dydxFormatter.shared.dollar(number: token?.usdcAmount, digits: 2)
        input.token = token?.token.rawValue
        if let tokenLogoUrl = token?.tokenLogoUrl {
            input.tokenIcon = URL(string: tokenLogoUrl)
        }
        if let chainLogoUrl = token?.chainLogoUrl {
            input.chainIcon = URL(string: chainLogoUrl)
        }
        input.assetAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/search", params: nil), animated: true, completion: nil)
        }
        input.amountInput = PlatformTextInputViewModel()
        viewModel?.input = input
    }
}
