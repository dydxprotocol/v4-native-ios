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
    @Published var position: SubaccountPosition?

    init(viewModel: dydxMarketPositionViewModel?) {
        super.init()

        self.viewModel = viewModel

        viewModel?.shareAction = {}
        viewModel?.closeAction = {[weak self] in
            if let assetId = self?.position?.assetId {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": "\(assetId)-USD"]), animated: true, completion: nil)
            }
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3($position.compactMap { $0 }.removeDuplicates(),
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] position, marketMap, assetMap in
                self?.updatePosition(position: position, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePosition(position: SubaccountPosition, marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        guard let sharedOrderViewModel = dydxPortfolioPositionsViewPresenter.createViewModelItem(position: position, marketMap: marketMap, assetMap: assetMap) else {
            return
        }

        guard let market = marketMap[position.id], let configs = market.configs else {
            return
        }

        viewModel?.unrealizedPNLAmount = sharedOrderViewModel.unrealizedPnl
        viewModel?.unrealizedPNLPercent = sharedOrderViewModel.unrealizedPnlPercent

        let sign: PlatformUISign
        let formattedPnl = dydxFormatter.shared.dollarVolume(number: abs(position.realizedPnl?.current?.doubleValue ?? 0), digits: 2)
        let formattedZero = dydxFormatter.shared.dollarVolume(number: 0.00, digits: 2)
        if formattedZero == formattedPnl {
            sign = .none
        } else if position.realizedPnlPercent?.current?.doubleValue ?? 0 > 0 {
            sign = .plus
        } else {
            sign = .minus
        }
        viewModel?.realizedPNLAmount = SignedAmountViewModel(text: formattedPnl, sign: sign, coloringOption: .allText)

        viewModel?.liquidationPrice = dydxFormatter.shared.dollar(number: position.liquidationPrice?.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.size = sharedOrderViewModel.size
        viewModel?.token = sharedOrderViewModel.token
        viewModel?.logoUrl = sharedOrderViewModel.logoUrl
        viewModel?.gradientType = sharedOrderViewModel.gradientType

        viewModel?.amount = dydxFormatter.shared.dollar(number: position.valueTotal?.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.openPrice = dydxFormatter.shared.dollar(number: position.entryPrice?.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        viewModel?.closePrice = dydxFormatter.shared.dollar(number: position.exitPrice?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        let fundingSign: PlatformUISign
        let funding = dydxFormatter.shared.dollarVolume(number: abs(position.netFunding?.doubleValue ?? 0), digits: 2)
        if formattedZero == funding {
            fundingSign = .none
        } else if position.netFunding?.doubleValue ?? 0 > 0 {
            fundingSign = .plus
        } else {
            fundingSign = .minus
        }
        viewModel?.funding = SignedAmountViewModel(text: funding, sign: fundingSign, coloringOption: .allText)
    }
}
