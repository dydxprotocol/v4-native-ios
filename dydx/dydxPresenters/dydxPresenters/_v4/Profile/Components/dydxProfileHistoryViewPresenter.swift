//
//  dydxProfileHistoryViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/23/23.
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
import SwiftUI

protocol dydxProfileHistoryViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileHistoryViewModel? { get }
}

class dydxProfileHistoryViewPresenter: HostedViewPresenter<dydxProfileHistoryViewModel>, dydxProfileHistoryViewPresenterProtocol {
    private let maxItemCount = 4

    override init() {
        super.init()

        viewModel = dydxProfileHistoryViewModel()
        viewModel?.tapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/portfolio/history"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.selectedSubaccountFills,
                            AbacusStateManager.shared.state.selectedSubaccountFundings,
                            AbacusStateManager.shared.state.transfers,
                            AbacusStateManager.shared.state.configsAndAssetMap.filter { $0.count > 0 }
            )
            .sink { [weak self] positions, fundings, transfers, configsAndAssetMap in
                self?.updateHistory(fills: positions, fundings: fundings, transfers: transfers, configsAndAsset: configsAndAssetMap)
            }
            .store(in: &subscriptions)
    }

    private func updateHistory(fills: [SubaccountFill], fundings: [SubaccountFundingPayment], transfers: [SubaccountTransfer], configsAndAsset: [String: MarketConfigsAndAsset]) {
        var fills = fills.prefix(maxItemCount)
        var fundings = fundings.prefix(maxItemCount)
        var transfers = transfers.prefix(maxItemCount)

        var items = [dydxProfileHistoryViewModel.Item?]()
        for _ in 0..<maxItemCount {
            let item = mostRecentOf(fill: fills.first, funding: fundings.first, transfer: transfers.first)
            if let item = item {
                if let fill = item as? SubaccountFill {
                    items.append(dydxProfileHistoryViewModel.Item(fill: fill, configsAndAsset: configsAndAsset))
                    fills.removeFirst()
                } else if let funding = item as? SubaccountFundingPayment {
                    items.append(dydxProfileHistoryViewModel.Item(funding: funding, configsAndAsset: configsAndAsset))
                    fundings.removeFirst()
                } else if let transfer = item as? SubaccountTransfer {
                    items.append(dydxProfileHistoryViewModel.Item(transfer: transfer))
                    transfers.removeFirst()
                }
            }
        }

        let newItems = items.filterNils()
        if newItems != viewModel?.items {
            let viewModel = dydxProfileHistoryViewModel()
            viewModel.items = newItems
            viewModel.tapAction = {
                Router.shared?.navigate(to: RoutingRequest(path: "/portfolio/history"), animated: true, completion: nil)
            }
            self.viewModel = viewModel
        }
    }

    private func mostRecentOf(fill: SubaccountFill?, funding: SubaccountFundingPayment?, transfer: SubaccountTransfer?) -> AnyObject? {
        if (fill?.createdAtMilliseconds ?? 0) > (funding?.effectiveAtMilliSeconds ?? 0),
           (fill?.createdAtMilliseconds ?? 0) > (transfer?.updatedAtMilliseconds ?? 0) {
            return fill
        } else if (funding?.effectiveAtMilliSeconds ?? 0) > (transfer?.updatedAtMilliseconds ?? 0) {
            return funding
        } else {
            return transfer
        }
    }
}

private extension dydxProfileHistoryViewModel.Item {
     convenience init?(fill: SubaccountFill, configsAndAsset: [String: MarketConfigsAndAsset]) {
         guard let configsAndAsset = configsAndAsset[fill.marketId], let configs = configsAndAsset.configs, let asset = configsAndAsset.asset else {
             return nil
         }
         let size = dydxFormatter.shared.localFormatted(number: fill.size, digits: configs.displayStepSizeDecimals?.intValue ?? 1)
         self.init(action: .fill(fill.side == Abacus.OrderSide.buy ?
                                    SideTextViewModel(side: .buy) :
                                    SideTextViewModel(side: .sell),
                                asset.displayableAssetId),
                   side: fill.side == Abacus.OrderSide.buy ?
                        SideTextViewModel(side: .long, coloringOption: .none) :
                        SideTextViewModel(side: .short, coloringOption: .none),
                   type: .string(DataLocalizer.localize(path: fill.resources.typeStringKey ?? "-")),
                   amount: size)
    }

    convenience init?(funding: SubaccountFundingPayment, configsAndAsset: [String: MarketConfigsAndAsset]) {
        guard let configsAndAsset = configsAndAsset[funding.marketId], let asset = configsAndAsset.asset else {
            return nil
        }
        let amount = dydxFormatter.shared.dollar(number: NSNumber(value: funding.payment), size: "0.0001")
        self.init(action: .string(DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT")),
                  side: funding.positionSize > 0 ?
                        SideTextViewModel(side: .long, coloringOption: .none) :
                        SideTextViewModel(side: .short, coloringOption: .none),
                  type: .token(TokenTextViewModel(symbol: asset.displayableAssetId)),
                  amount: amount)
    }

    convenience init?(transfer: SubaccountTransfer) {
        let type: String
        if let typeStringKey = transfer.resources.typeStringKey {
            type = DataLocalizer.localize(path: typeStringKey)
        } else {
            type = "-"
        }
        let amount = dydxFormatter.shared.localFormatted(number: NSNumber(value: transfer.amount?.doubleValue ?? 0), size: "0.01")
        self.init(action: .string(type),
                  side: SideTextViewModel(side: .custom("-"), coloringOption: .none),
                  type: .token(TokenTextViewModel(symbol: transfer.asset ?? "-")),
                  amount: amount)
    }
}
