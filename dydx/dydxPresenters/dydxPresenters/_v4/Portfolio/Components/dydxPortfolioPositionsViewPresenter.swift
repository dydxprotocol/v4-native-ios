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
    init(viewModel: dydxPortfolioPositionsViewModel?) {
        super.init()

        self.viewModel = viewModel

        viewModel?.vaultTapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/vault"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.emptyText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS")
                } else {
                    self?.viewModel?.emptyText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS_LOG_IN")
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.selectedSubaccountPositions,
                            AbacusStateManager.shared.state.selectedSubaccountPendingPositions,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] positions, pendingPositions, marketMap, assetMap in
                self?.updatePositions(positions: positions, marketMap: marketMap, assetMap: assetMap)
                self?.updatePendingPositions(pendingPositions: pendingPositions, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            // TODO: replace with actual vault info from abacus
            AbacusStateManager.shared.state.onboarded
        ).sink { [weak self] onboarded, _ in
            if onboarded,
                let viewModel = self?.viewModel,
               // TODO: replace with actual vault info from abacus
                let vaultBalance = Double?(420.42),
                let vaultApy = Double?(Double.random(in: -30...30)) {
                viewModel.vaultBalance = dydxFormatter.shared.dollar(number: vaultBalance, digits: 2)
                viewModel.vaultApy = vaultApy
            }
        }
        .store(in: &subscriptions)
    }

    private func updatePositions(positions: [SubaccountPosition], marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        let items: [dydxPortfolioPositionItemViewModel] = positions.compactMap { position -> dydxPortfolioPositionItemViewModel? in
            Self.createPositionViewModelItem(position: position,
                                                        marketMap: marketMap,
                                                        assetMap: assetMap)
        }

        self.viewModel?.positionItems = items
    }

    private func updatePendingPositions(pendingPositions: [SubaccountPendingPosition], marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        let items: [dydxPortfolioPendingPositionsItemViewModel] = pendingPositions.compactMap { pendingPosition -> dydxPortfolioPendingPositionsItemViewModel? in
            Self.createPendingPositionsViewModelItem(pendingPosition: pendingPosition,
                                                                marketMap: marketMap,
                                                                assetMap: assetMap)
        }

        self.viewModel?.pendingPositionItems = items
    }

    static func createPendingPositionsViewModelItem(
        pendingPosition: SubaccountPendingPosition,
        marketMap: [String: PerpetualMarket],
        assetMap: [String: Asset],
        pendingPositionsCache: [String: dydxPortfolioPendingPositionsItemViewModel]? = nil
    ) -> dydxPortfolioPendingPositionsItemViewModel? {

        guard let market = marketMap[pendingPosition.marketId],
              let asset = assetMap[pendingPosition.assetId],
              let margin = pendingPosition.equity?.current?.doubleValue,
              margin != 0,
              let marginFormatted = dydxFormatter.shared.dollar(number: margin, digits: 2)
        else {
            return nil
        }

        let viewOrdersAction: () -> Void = {
            let routingRequest = RoutingRequest(
                path: "/market",
                params: ["market": market.id,
                         "currentSection": "orders"])
            Router.shared?.navigate(to: routingRequest,
                                    animated: true,
                                    completion: nil)
        }

        let cancelOrdersAction: () -> Void = {
            Router.shared?.navigate(to: RoutingRequest(path: "/portfolio/cancel_pending_position/\(market.id)"), animated: true, completion: nil)
        }

        return dydxPortfolioPendingPositionsItemViewModel(marketLogoUrl: URL(string: asset.resources?.imageUrl ?? ""),
                                                          marketName: asset.name!,
                                                          margin: marginFormatted,
                                                          orderCount: pendingPosition.orderCount,
                                                          viewOrdersAction: viewOrdersAction,
                                                          cancelOrdersAction: cancelOrdersAction)
    }

    static func createPositionViewModelItem(position: SubaccountPosition, marketMap: [String: PerpetualMarket], assetMap: [String: Asset], positionsCache: [String: dydxPortfolioPositionItemViewModel]? = nil) -> dydxPortfolioPositionItemViewModel? {
        guard let market = marketMap[position.id], let configs = market.configs, let asset = assetMap[position.assetId],
              (position.size.current?.doubleValue ?? 0) != 0 else {
            return nil
        }

        let item = positionsCache?[position.assetId] ?? dydxPortfolioPositionItemViewModel()

        let positionSize = abs(position.size.current?.doubleValue ?? 0)
        let notionalValue = abs(position.notionalTotal.current?.doubleValue ?? 0)
        item.size = dydxFormatter.shared.localFormatted(number: positionSize, digits: configs.displayStepSizeDecimals?.intValue ?? 1)
        item.notionalValue = dydxFormatter.shared.dollar(number: notionalValue, digits: 2) ?? "--"
        item.token?.symbol = asset.id

        if position.resources.indicator.current == "long" {
            item.sideText.side = .long
            item.gradientType = .plus
        } else {
            item.sideText.side = .short
            item.gradientType = .minus
        }

        item.leverage = dydxFormatter.shared.leverage(number: NSNumber(value: position.leverage.current?.doubleValue ?? 0))
        if let leverage = position.leverage.current?.doubleValue, let maxLeverage = position.maxLeverage.current?.doubleValue, maxLeverage > 0 {
            item.leverageIcon = LeverageRiskModel(level: LeverageRiskModel.Level(marginUsage: leverage / maxLeverage), viewSize: 16, displayOption: .iconOnly)
        }

        item.indexPrice = dydxFormatter.shared.dollar(number: market.oraclePrice, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        if let liquidationPrice = position.liquidationPrice.current {
            item.liquidationPrice = dydxFormatter.shared.dollar(number: liquidationPrice, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        } else {
            item.liquidationPrice = DataLocalizer.localize(path: "APP.GENERAL.NONE")
        }

        item.unrealizedPnl = SignedAmountViewModel(amount: position.unrealizedPnl.current?.doubleValue ?? 0, displayType: .dollar, coloringOption: .allText)
        item.unrealizedPnlPercent = dydxFormatter.shared.percent(number: position.unrealizedPnlPercent.current?.doubleValue, digits: 2) ?? ""

        if let marginMode = position.marginMode {
            item.marginMode = DataLocalizer.shared?.localize(path: "APP.GENERAL.\(marginMode.rawValue)", params: nil) ?? "--"
            item.isMarginAdjustable = marginMode == .isolated
            item.marginValue = dydxFormatter.shared.dollar(number: position.marginValue.current?.doubleValue, digits: 2) ?? "--"
            switch marginMode {
            case .cross:
                item.isMarginAdjustable = false
            case .isolated:
                item.isMarginAdjustable = true
            default:
                assertionFailure("no margin mode")
                break
            }
        }

        if let url = asset.resources?.imageUrl {
            item.logoUrl = URL(string: url)
        }

        item.handler?.onTapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["market": market.id]), animated: true, completion: nil)
        }
        item.handler?.onCloseAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": market.id]), animated: true, completion: nil)
        }
        item.handler?.onMarginEditAction = {
            let routingRequest = RoutingRequest(
                path: "/trade/adjust_margin",
                params: [
                    "marketId": market.id,
                    "childSubaccountNumber": position.childSubaccountNumber?.stringValue as Any
            ])
            Router.shared?.navigate(to: routingRequest,
                                    animated: true,
                                    completion: nil)
        }

        return item
    }
}
