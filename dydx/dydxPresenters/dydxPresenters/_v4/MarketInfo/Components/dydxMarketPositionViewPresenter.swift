//
//  dydxMarketPositionViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/11/23.
//

import Abacus
import Combine
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import dydxFormatter

protocol dydxMarketPositionViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketPositionViewModel? { get }
}

class dydxMarketPositionViewPresenter: HostedViewPresenter<dydxMarketPositionViewModel>, dydxMarketPositionViewPresenterProtocol {
    @Published var position: SubaccountPosition? {
        didSet {
            tpSlPresenter.position = position
        }
    }
    @Published var pendingPosition: SubaccountPendingPosition?

    private let tpSlPresenter = dydxMarketTpSlGroupViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        tpSlPresenter
    ]

    init(viewModel: dydxMarketPositionViewModel?) {
        super.init()

        self.viewModel = viewModel

        viewModel?.closeAction = {[weak self] in
            if let marketId = self?.position?.id {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": "\(marketId)"]), animated: true, completion: nil)
            }
        }

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        tpSlPresenter.$viewModel
            .sink { [weak self] tpSlGroupViewModel in
                self?.viewModel?.tpSlGroupViewModel = tpSlGroupViewModel
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3($pendingPosition,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] pendingPosition, marketMap, assetMap in
                if let pendingPosition {
                    self?.viewModel?.pendingPosition = dydxPortfolioPositionsViewPresenter.createPendingPositionsViewModelItem(
                        pendingPosition: pendingPosition,
                        marketMap: marketMap,
                        assetMap: assetMap)
                } else {
                    self?.viewModel?.pendingPosition = nil
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(AbacusStateManager.shared.state.onboarded,
                            $position.removeDuplicates())
            .sink { [weak self] (onboarded, position) in
                if !onboarded {
                    self?.viewModel?.emptyText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS_LOG_IN")
                } else if position == nil {
                    self?.viewModel?.emptyText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS")
                } else {
                    self?.viewModel?.emptyText = nil
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4($position.compactMap { $0 }.removeDuplicates(),
                            AbacusStateManager.shared.state.selectedSubaccountTriggerOrders,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] position, triggerOrders, marketMap, assetMap in
                self?.updatePosition(position: position, triggerOrders: triggerOrders, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePosition(position: SubaccountPosition, triggerOrders: [SubaccountOrder], marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        guard let sharedOrderViewModel = dydxPortfolioPositionsViewPresenter.createPositionViewModelItem(position: position, marketMap: marketMap, assetMap: assetMap) else {
            return
        }

        guard let market = marketMap[position.id], let configs = market.configs else {
            return
        }

        switch position.marginMode {
        case .isolated:
            viewModel?.editMarginAction = {
                let routingRequest = RoutingRequest(
                    path: "/trade/adjust_margin",
                    params: ["marketId": market.id,
                             "childSubaccountNumber": position.childSubaccountNumber?.stringValue as Any])
                Router.shared?.navigate(to: routingRequest,
                                        animated: true,
                                        completion: nil)
            }
        default:
            viewModel?.editMarginAction = nil
        }

        viewModel?.unrealizedPNLAmount = sharedOrderViewModel.unrealizedPnl
        viewModel?.unrealizedPNLPercent =  dydxFormatter.shared.percent(number: position.unrealizedPnlPercent.current?.doubleValue, digits: 2) ?? ""
        viewModel?.realizedPNLAmount = SignedAmountViewModel(amount: position.realizedPnl.current?.doubleValue, displayType: .dollar, coloringOption: .allText)

        if  let marginMode = position.marginMode {
            viewModel?.marginMode = DataLocalizer.shared?.localize(path: "APP.GENERAL.\(marginMode.rawValue.uppercased())", params: nil)
        }
        if let margin = position.marginValue.current?.doubleValue {
            viewModel?.margin = dydxFormatter.shared.dollar(number: NSNumber(value: margin), digits: 2)
        }

        viewModel?.liquidationPrice = dydxFormatter.shared.dollar(number: position.liquidationPrice.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.leverage = sharedOrderViewModel.leverage
        viewModel?.leverageIcon = sharedOrderViewModel.leverageIcon
        viewModel?.size = sharedOrderViewModel.size
        viewModel?.side = SideTextViewModel(side: sharedOrderViewModel.sideText.side, coloringOption: .withBackground)
        viewModel?.token = sharedOrderViewModel.token
        viewModel?.logoUrl = sharedOrderViewModel.logoUrl
        viewModel?.gradientType = sharedOrderViewModel.gradientType

        viewModel?.amount = dydxFormatter.shared.dollar(number: position.notionalTotal.current?.doubleValue, digits: 2)

        viewModel?.openPrice = dydxFormatter.shared.dollar(number: position.entryPrice.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        viewModel?.closePrice = dydxFormatter.shared.dollar(number: position.exitPrice?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.funding = SignedAmountViewModel(amount: position.netFunding?.doubleValue, displayType: .dollar, coloringOption: .allText)
    }
}
