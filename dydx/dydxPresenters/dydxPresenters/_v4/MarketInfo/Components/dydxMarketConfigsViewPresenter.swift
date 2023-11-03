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

        let marketConfigsPublisher = $marketId
            .compactMap { $0 }
            .flatMap { AbacusStateManager.shared.state.market(of: $0) }
            .compactMap(\.?.configs)
            .compactMap { $0 }

        marketConfigsPublisher
            .sink { [weak self] marketConfigs in
                self?.updateConfigs(marketConfigs: marketConfigs)
            }
            .store(in: &subscriptions)
    }

    private func updateConfigs(marketConfigs: MarketConfigs) {
        let maxLeverageText: String?
        if let imf = marketConfigs.initialMarginFraction?.doubleValue {
            maxLeverageText = dydxFormatter.shared.naturalLocalFormatted(number: NSNumber(value: 1.0 / imf))
        } else {
            maxLeverageText = nil
        }

        let tickSize = dydxFormatter.shared.format(decimal: marketConfigs.tickSize?.decimalValue)
        viewModel?.items = [
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MARKET_NAME"), value: marketId ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.TICK_SIZE"), value: tickSize ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.STEP_SIZE"), value: "\(marketConfigs.stepSize?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MINIMUM_ORDER_SIZE"), value: "\(marketConfigs.minOrderSize?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MAXIMUM_LEVERAGE"), value: maxLeverageText ?? "-"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.MAINTENANCE_MARGIN_FRACTION"), value: "\(marketConfigs.maintenanceMarginFraction?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.GENERAL.INITIAL_MARGIN_FRACTION"), value: "\(marketConfigs.initialMarginFraction?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.INCREMENTAL_INITIAL_MARGIN_FRACTION"), value: "\(marketConfigs.incrementalInitialMarginFraction?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.INCREMENTAL_POSITION_SIZE"), value: "\(marketConfigs.incrementalPositionSize?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.BASELINE_POSITION_SIZE"), value: "\(marketConfigs.baselinePositionSize?.doubleValue ?? 0)"),
            dydxMarketConfigsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.MAXIMUM_POSITION_SIZE"), value: "\(marketConfigs.maxPositionSize?.doubleValue ?? 0)")
        ]
    }
}
