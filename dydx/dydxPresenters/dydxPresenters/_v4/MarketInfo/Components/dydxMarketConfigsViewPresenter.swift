//
//  dydxMarketResourcesView.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter

protocol dydxMarketConfigsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketConfigsViewModel? { get }
}

class dydxMarketConfigsViewPresenter: HostedViewPresenter<dydxMarketConfigsViewModel>, dydxMarketConfigsViewPresenterProtocol {
    @Published var marketId: String?

    override init() {
        super.init()

        viewModel = dydxMarketConfigsViewModel()
    }

    override func start() {
        super.start()

        $marketId
            .compactMap { $0 }
            .flatMap { AbacusStateManager.shared.state.market(of: $0) }
            .compactMap { $0 }
            .sink { [weak self] market in
                self?.updateConfigs(market: market)
            }
            .store(in: &subscriptions)
    }

    private func updateConfigs(market: PerpetualMarket) {
        let marketConfigs = market.configs

        let maxLeverageText: String?
        if let imf = marketConfigs?.initialMarginFraction?.doubleValue {
            maxLeverageText = dydxFormatter.shared.naturalLocalFormatted(number: NSNumber(value: 1.0 / imf))
        } else {
            maxLeverageText = nil
        }

        let tickSize = dydxFormatter.shared.format(decimal: marketConfigs?.tickSize?.decimalValue)
        viewModel?.items = [
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MARKET_NAME"),
                                            value: marketId ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.TICK_SIZE"),
                                            value: tickSize != nil ? "$" + (tickSize ?? "") : "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.STEP_SIZE"),
                                            value: marketConfigs?.stepSize?.doubleValue != nil ? "\(marketConfigs?.stepSize?.doubleValue ?? 0)" : "-",
                                            token: marketConfigs?.stepSize?.doubleValue != nil ? TokenTextViewModel(symbol: market.assetId) : nil),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MINIMUM_ORDER_SIZE"),
                                            value: marketConfigs?.minOrderSize?.doubleValue != nil ? "\(marketConfigs?.minOrderSize?.doubleValue ?? 0)" : "-",
                                            token: marketConfigs?.minOrderSize?.doubleValue != nil ? TokenTextViewModel(symbol: market.assetId) : nil),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MAXIMUM_LEVERAGE"),
                                            value: maxLeverageText ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MAINTENANCE_MARGIN_FRACTION"),
                                            value: dydxFormatter.shared.percent(number: marketConfigs?.maintenanceMarginFraction?.doubleValue, digits: 4) ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.INITIAL_MARGIN_FRACTION"),
                                            value: dydxFormatter.shared.percent(number: marketConfigs?.initialMarginFraction?.doubleValue, digits: 4) ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.INCREMENTAL_INITIAL_MARGIN_FRACTION"),
                                            value: dydxFormatter.shared.percent(number: marketConfigs?.incrementalInitialMarginFraction?.doubleValue, digits: 4) ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.BASE_POSITION_NOTIONAL"),
                                            value: dydxFormatter.shared.localFormatted(number: marketConfigs?.basePositionNotional?.doubleValue, digits: 0) ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.INCREMENTAL_POSITION_SIZE"),
                                            value: marketConfigs?.incrementalPositionSize?.doubleValue != nil ? "\(marketConfigs?.incrementalPositionSize?.doubleValue ?? 0)" : "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.BASELINE_POSITION_SIZE"),
                                            value: marketConfigs?.baselinePositionSize?.doubleValue != nil ? "\(marketConfigs?.baselinePositionSize?.doubleValue ?? 0)" : "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.MAXIMUM_POSITION_SIZE"),
                                            value: marketConfigs?.maxPositionSize?.doubleValue != nil ? "\(marketConfigs?.maxPositionSize?.doubleValue ?? 0)" : "-")
        ]
    }
}
