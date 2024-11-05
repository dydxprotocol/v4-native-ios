//
//  dydxPortfolioFillsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/6/23.
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

protocol dydxPortfolioFillsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioFillsViewModel? { get }
}

class dydxPortfolioFillsViewPresenter: HostedViewPresenter<dydxPortfolioFillsViewModel>, dydxPortfolioFillsViewPresenterProtocol {
    @Published var filterByMarketId: String?

    private var cache = [String: SharedFillViewModel]()

    init(viewModel: dydxPortfolioFillsViewModel?) {
        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_TRADES")
                } else {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_TRADES_LOG_IN")
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountFills,
                            AbacusStateManager.shared.state.configsAndAssetMap,
                            $filterByMarketId)
            .sink { [weak self] fills, configsAndAssetMap, filterByMarketId in
                self?.updateFills(fills: fills, configsAndAssetMap: configsAndAssetMap, filterByMarketId: filterByMarketId)

            }
            .store(in: &subscriptions)
    }

    private func updateFills(fills: [SubaccountFill], configsAndAssetMap: [String: MarketConfigsAndAsset], filterByMarketId: String?) {
        let items: [SharedFillViewModel] = fills.compactMap { fill -> SharedFillViewModel? in
            if let filterByMarketId = filterByMarketId, filterByMarketId != fill.marketId {
                return nil
            }

            let item = Self.createViewModelItem(fill: fill, configsAndAssetMap: configsAndAssetMap, cache: cache)
            cache[fill.id] = item
            return item
        }
        viewModel?.items = items
    }

    static func createViewModelItem(fill: SubaccountFill, configsAndAssetMap: [String: MarketConfigsAndAsset], cache: [String: SharedFillViewModel]? = nil) -> SharedFillViewModel? {
        guard let configsAndAsset = configsAndAssetMap[fill.marketId], let configs = configsAndAsset.configs, let asset = configsAndAsset.asset else {
            return nil
        }

        let item = cache?[fill.id] ?? SharedFillViewModel()

        item.type = DataLocalizer.localize(path: fill.resources.typeStringKey ?? "-")
        item.size = dydxFormatter.shared.localFormatted(number: fill.size, digits: configs.displayStepSizeDecimals?.intValue ?? 1)
        item.token?.symbol = asset.displayableAssetId
        item.date = Date(milliseconds: fill.createdAtMilliseconds)
        if let tickSize = configs.displayTickSizeDecimals?.intValue {
            item.price = dydxFormatter.shared.dollar(number: fill.price, digits: tickSize)
            item.fee = dydxFormatter.shared.dollar(number: fill.fee, digits: tickSize)
        }
        item.feeLiquidity = DataLocalizer.localize(path: fill.resources.liquidityStringKey ?? "-")
        if fill.side == Abacus.OrderSide.buy {
            item.sideText.side = .buy
        } else {
            item.sideText.side = .sell
        }
        if let url = asset.resources?.imageUrl {
            item.logoUrl = URL(string: url)
        }
        item.handler?.onTapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/order", params: ["id": fill.id]), animated: true, completion: nil)
        }

        return item
    }
}
