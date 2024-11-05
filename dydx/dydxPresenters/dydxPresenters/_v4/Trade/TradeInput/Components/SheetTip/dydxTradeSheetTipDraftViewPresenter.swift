//
//  dydxTradeSheetTipDraftViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 9/26/23.
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
import Combine

protocol dydxTradeSheetTipDraftViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeSheetTipDraftViewModel? { get }
}

class dydxTradeSheetTipDraftViewPresenter: HostedViewPresenter<dydxTradeSheetTipDraftViewModel>, dydxTradeSheetTipDraftViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeSheetTipDraftViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .sink { [weak self] tradeInput, configsAndAssetMap in
                if let marketId = tradeInput.marketId {
                    self?.updateViewModel(tradeInput: tradeInput, configsAndAsset: configsAndAssetMap[marketId])
                }
            }
            .store(in: &subscriptions)
    }

    private func updateViewModel(tradeInput: TradeInput, configsAndAsset: MarketConfigsAndAsset?) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        switch tradeInput.side {
        case Abacus.OrderSide.buy:
            viewModel?.side = SideTextViewModel(side: .buy, coloringOption: .withBackground)
        case Abacus.OrderSide.sell:
            viewModel?.side = SideTextViewModel(side: .sell, coloringOption: .withBackground)
        default:
            viewModel?.side = nil
        }

        if let size = tradeInput.size?.size, let stepSize = marketConfigs?.displayStepSize {
            viewModel?.size = SizeTextModel(amount: size,
                                            stepSize: Parser.standard.asString(stepSize))
        } else {
            viewModel?.size = nil
        }

        if let token = asset?.displayableAssetId ?? configsAndAsset?.assetId {
            viewModel?.token = TokenTextViewModel(symbol: token)
        }

        viewModel?.type = tradeInput.selectedTypeText

        let price: Double?
        switch tradeInput.type {
        case Abacus.OrderType.limit, Abacus.OrderType.stoplimit, Abacus.OrderType.takeprofitlimit:
            price = tradeInput.price?.limitPrice?.doubleValue
        case Abacus.OrderType.stopmarket, Abacus.OrderType.takeprofitmarket:
            price = tradeInput.price?.triggerPrice?.doubleValue
        case Abacus.OrderType.market:
            if let usdcSize = tradeInput.size?.usdcSize?.doubleValue, let size = tradeInput.size?.size?.doubleValue, size > 0 {
                price = usdcSize / size
            } else {
                price = nil
            }
        default:
            assertionFailure("unexpected trade type \(String(describing: tradeInput.type))")
            price = nil
        }
        if let price = price {
            viewModel?.price = AmountTextModel(amount: NSNumber(floatLiteral: price),
                                               tickSize: NSDecimalNumber(decimal: marketConfigs?.displayTickSize?.decimalValue ?? 0.01))
        } else {
            viewModel?.price = nil
        }
    }
}
