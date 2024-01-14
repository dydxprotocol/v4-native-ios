//
//  dydxPortfolioPositionsViewPresenter.swift
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

protocol dydxPortfolioPositionsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioPositionsViewModel? { get }
}

class dydxPortfolioPositionsViewPresenter: HostedViewPresenter<dydxPortfolioPositionsViewModel>, dydxPortfolioPositionsViewPresenterProtocol {
    private var cache = [String: dydxPortfolioPositionItemViewModel]()

    init(viewModel: dydxPortfolioPositionsViewModel?) {
        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS")
                } else {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS_LOG_IN")
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountPositions,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] positions, marketMap, assetMap in
                self?.updatePositions(positions: positions, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePositions(positions: [SubaccountPosition], marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        let items: [dydxPortfolioPositionItemViewModel] = positions.compactMap { position -> dydxPortfolioPositionItemViewModel? in
            let item = Self.createViewModelItem(position: position, marketMap: marketMap, assetMap: assetMap, cache: cache)
            cache[position.assetId] = item
            return item
        }

        self.viewModel?.items = items
    }

    static func createViewModelItem(position: SubaccountPosition, marketMap: [String: PerpetualMarket], assetMap: [String: Asset], cache: [String: dydxPortfolioPositionItemViewModel]? = nil) -> dydxPortfolioPositionItemViewModel? {
        guard let market = marketMap[position.id], let configs = market.configs, let asset = assetMap[position.assetId],
              (position.size?.current?.doubleValue ?? 0) != 0 else {
            return nil
        }

        let item = cache?[position.assetId] ?? dydxPortfolioPositionItemViewModel()

        let positionSize = abs(position.size?.current?.doubleValue ?? 0)
        item.size = dydxFormatter.shared.localFormatted(number: positionSize, digits: configs.displayStepSizeDecimals?.intValue ?? 1)
        item.token?.symbol = asset.id

        if position.resources.indicator.current == "long" {
            item.sideText.side = .long
            item.gradientType = .plus
        } else {
            item.sideText.side = .short
            item.gradientType = .minus
       }

        item.notional = dydxFormatter.shared.dollar(number: NSNumber(value: position.notionalTotal?.current?.doubleValue ?? 0), digits: 2)
        item.leverage = dydxFormatter.shared.leverage(number: NSNumber(value: position.leverage?.current?.doubleValue ?? 0))
        if let leverage = position.leverage?.current?.doubleValue, let maxLeverage = position.maxLeverage?.current?.doubleValue, maxLeverage > 0 {
            item.leverageIcon = LeverageRiskModel(level: LeverageRiskModel.Level(marginUsage: leverage / maxLeverage), viewSize: 16, displayOption: .iconOnly)
        }
        item.indexPrice = dydxFormatter.shared.dollar(number: market.oraclePrice, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        item.entryPrice = dydxFormatter.shared.dollar(number: position.entryPrice?.current, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        let sign: PlatformUISign
        if position.unrealizedPnlPercent?.current?.doubleValue ?? 0 > 0 {
            sign = .plus
        } else if position.unrealizedPnlPercent?.current?.doubleValue ?? 0 < 0 {
            sign = .minus
        } else {
            sign = .none
        }
        let pnlPercent = dydxFormatter.shared.percent(number: abs(position.unrealizedPnlPercent?.current?.doubleValue ?? 0), digits: 2)
        item.unrealizedPnlPercent = SignedAmountViewModel(text: pnlPercent, sign: sign, coloringOption: .allText)

        let pnl = dydxFormatter.shared.dollarVolume(number: abs(position.unrealizedPnl?.current?.doubleValue ?? 0), digits: 2)
        item.unrealizedPnl =  SignedAmountViewModel(text: pnl, sign: sign, coloringOption: .signOnly)

        if let url = asset.resources?.imageUrl {
            item.logoUrl = URL(string: url)
        }

        item.handler?.onTapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["market": market.id]), animated: true, completion: nil)
        }
        item.handler?.onCloseAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": "\(position.assetId)-USD"]), animated: true, completion: nil)
        }

        return item
    }
}
