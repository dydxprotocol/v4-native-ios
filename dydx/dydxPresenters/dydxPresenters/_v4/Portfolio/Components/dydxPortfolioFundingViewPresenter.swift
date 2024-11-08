//
//  dydxPortfolioFundingViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/8/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Combine
import dydxFormatter

protocol dydxPortfolioFundingViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioFundingViewModel? { get }
}

class dydxPortfolioFundingViewPresenter: HostedViewPresenter<dydxPortfolioFundingViewModel>, dydxPortfolioFundingViewPresenterProtocol {
    @Published var filterByMarketId: String?

    private var cache = [Double: dydxPortfolioFundingItemViewModel]()

    init(viewModel: dydxPortfolioFundingViewModel?) {
        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_FUNDING")
                } else {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_FUNDING_LOG_IN")
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountFundings,
                            AbacusStateManager.shared.state.configsAndAssetMap,
                            $filterByMarketId)
             .sink { [weak self] fundings, configsAndAssetMap, filterByMarketId in
                self?.updatefundings(fundings: fundings, configsAndAssetMap: configsAndAssetMap, filterByMarketId: filterByMarketId)
            }
            .store(in: &subscriptions)
    }

    private func updatefundings(fundings: [SubaccountFundingPayment], configsAndAssetMap: [String: MarketConfigsAndAsset], filterByMarketId: String?) {
        let items: [dydxPortfolioFundingItemViewModel] = fundings.compactMap { funding -> dydxPortfolioFundingItemViewModel? in
            if let filterByMarketId = filterByMarketId, filterByMarketId != funding.marketId {
                return nil
            }
            guard let configsAndAsset = configsAndAssetMap[funding.marketId], let configs = configsAndAsset.configs, let asset = configsAndAsset.asset else {
                return nil
            }

            let item = cache[funding.effectiveAtMilliSeconds] ?? dydxPortfolioFundingItemViewModel()
            cache[funding.effectiveAtMilliSeconds] = item

            item.time = dydxFormatter.shared.interval(time: Date(milliseconds: funding.effectiveAtMilliSeconds))
            let amount = dydxFormatter.shared.dollar(number: abs(funding.payment), size: "0.0001")
            if funding.payment >= 0.0 {
                item.amount = SignedAmountViewModel(text: amount, sign: .plus, coloringOption: .signOnly)
                item.status = .earned
            } else {
                item.amount = SignedAmountViewModel(text: amount, sign: .minus, coloringOption: .signOnly)
                item.status = .paid
            }
            item.rate = SignedAmountViewModel(text: dydxFormatter.shared.percent(number: abs(funding.rate), digits: 6),
                                                    sign: funding.rate >= 0.0 ? .plus : .minus,
                                                   coloringOption: .allText)
            item.sideText.side = funding.positionSize > 0 ? .long : .short
            let position = dydxFormatter.shared.raw(number: NSNumber(value: abs(funding.positionSize)), digits: configs.displayStepSizeDecimals?.intValue ?? 1)
            item.position = position
            item.token?.symbol = asset.displayableAssetId
            if let url = asset.resources?.imageUrl {
                item.logoUrl = URL(string: url)
            }
            return item
        }

        self.viewModel?.items = items
    }
}
