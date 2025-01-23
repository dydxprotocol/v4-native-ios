//
//  dydxClosePositionInputCtaButtonViewPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 2/16/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import Combine
import dydxStateManager

protocol dydxClosePositionInputCtaButtonViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputCtaButtonViewModel? { get }
}

class dydxClosePositionInputCtaButtonViewPresenter: HostedViewPresenter<dydxTradeInputCtaButtonViewModel>, dydxTradeInputCtaButtonViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeInputCtaButtonViewModel()
        viewModel?.ctaAction = {[weak self] in
            self?.closePosition()
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.closePositionInput,
                AbacusStateManager.shared.state.validationErrors)
            .sink { [weak self] closePositionInput, tradeErrors in
                self?.update(closePositionInput: closePositionInput, tradeErrors: tradeErrors)
            }
            .store(in: &subscriptions)
    }

    private func update(closePositionInput: ClosePositionInput?, tradeErrors: [ValidationError]) {
        if closePositionInput?.size?.size?.doubleValue ?? 0 > 0 {
            let firstBlockingError = tradeErrors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
            if let firstBlockingError = firstBlockingError {
                viewModel?.ctaButtonState = .disabled(firstBlockingError.resources.action?.localizedString)
            } else {
                viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.TRADE.CLOSE_POSITION"))
            }
        } else {
            viewModel?.ctaButtonState = .disabled()
        }
    }

    private func closePosition() {
        AbacusStateManager.shared.state.hasAccount
            .prefix(1)
            .sink { hasAccount in
                if hasAccount {
                    Router.shared?.navigate(to: RoutingRequest(path: "/closePosition/status"), animated: true, completion: nil)
                } else {
                    Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
                }
            }
            .store(in: &subscriptions)
    }
}
