//
//  dydxPortfolioFeesViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 8/5/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import dydxFormatter

protocol dydxPortfolioFeesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioFeesViewModel? { get }
}

class dydxPortfolioFeesViewPresenter: HostedViewPresenter<dydxPortfolioFeesViewModel>, dydxPortfolioFeesViewPresenterProtocol {
    init(viewModel: dydxPortfolioFeesViewModel?) {
        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.configs
                .map(\.?.feeTiers),
            AbacusStateManager.shared.state.user
        )
            .sink { [weak self] feeTiers, user in
                self?.updateFees(feeTiers: feeTiers, user: user)
            }
            .store(in: &subscriptions)
    }

    private func updateFees(feeTiers: [FeeTier]?, user: User?) {
        if let user = user {
            let volume30D = user.makerVolume30D + user.takerVolume30D
            viewModel?.tradingVolume = dydxFormatter.shared.dollarVolume(number: volume30D)
        } else {
            viewModel?.tradingVolume = nil
        }

        viewModel?.feeTierList.items = feeTiers?.compactMap { tier in
            createItemViewModel(tier: tier, userAtTierId: user?.feeTierId)
        } ?? []

        viewModel?.objectWillChange.send()
    }

    private func createItemViewModel(tier: FeeTier, userAtTierId: String?) -> dydxPortfolioFeesItemViewModel {
        var conditions = [dydxPortfolioFeesItemViewModel.Condition]()
        if let volume = dydxFormatter.shared.condensed(number: Parser.standard.asNumber(tier.volume), digits: 0) {
            conditions.append(dydxPortfolioFeesItemViewModel.Condition(title: nil,
                                                                       value: "\(tier.symbol) \(volume)"))
        }
        if let totalShare = tier.totalShare?.doubleValue, totalShare > 0,
           let value = dydxFormatter.shared.percent(number: totalShare, digits: 3) {
            let title = DataLocalizer.localize(path: "APP.FEE_TIERS.AND_EXCHANGE_MARKET_SHARE")
            conditions.append(dydxPortfolioFeesItemViewModel.Condition(title: title,
                                                                       value: "> \(value)"))
        }
        if let makerShare = tier.makerShare?.doubleValue, makerShare > 0,
           let value = dydxFormatter.shared.percent(number: makerShare, digits: 3) {
            let title = DataLocalizer.localize(path: "APP.FEE_TIERS.AND_MAKER_MARKET_SHARE")
            conditions.append(dydxPortfolioFeesItemViewModel.Condition(title: title,
                                                                       value: "> \(value)"))
        }
        return dydxPortfolioFeesItemViewModel(tier: tier.id,    // TODO: Use resources
                                              conditions: conditions,
                                              makerPercent: dydxFormatter.shared.percent(number: tier.maker, digits: 3),
                                              takerPercent: dydxFormatter.shared.percent(number: tier.taker, digits: 3),
                                              isUserTier: tier.id == userAtTierId)
    }
}
