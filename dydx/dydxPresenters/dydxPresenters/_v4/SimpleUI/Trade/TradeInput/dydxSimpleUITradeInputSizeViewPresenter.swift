//
//  dydxSimpleUITradeInputSizeViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 02/01/2025.
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

protocol dydxSimpleUITradeInputSizeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUITradeInputSizeViewModel? { get }
}

class dydxSimpleUITradeInputSizeViewPresenter: HostedViewPresenter<dydxSimpleUITradeInputSizeViewModel>, dydxSimpleUITradeInputSizeViewPresenterProtocol {

    private lazy var sizeItem: dydxSimpleUITradeInputSizeItemViewModel = {
        let item = dydxSimpleUITradeInputSizeItemViewModel(label: nil, placeHolder: "0.000", onEdited: { value in
            AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue,
                                            type: TradeInputField.size)
        })
        item.showingUsdc = false
        return item
    }()

    private lazy var usdSizeItem: dydxSimpleUITradeInputSizeItemViewModel = {
        let item = dydxSimpleUITradeInputSizeItemViewModel(label: nil, placeHolder: "0.000", onEdited: { value in
            AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue,
                                            type: TradeInputField.usdcsize)
        })
        item.showingUsdc = true
        return item
    }()

    override init() {
        super.init()

        viewModel = dydxSimpleUITradeInputSizeViewModel()
        viewModel?.sizeItem = sizeItem
        viewModel?.usdSizeItem = usdSizeItem
        viewModel?.showingUsdc = true
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 }.removeDuplicates(),
                AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] tradeInput, configsAndAssetMap in
                if let marketId = tradeInput.marketId {
                    self?.update(tradeInput: tradeInput, configsAndAsset: configsAndAssetMap[marketId])
                }
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput, configsAndAsset: MarketConfigsAndAsset?) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        viewModel?.sizeItem.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
        viewModel?.sizeItem.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id

        for itemViewModel in [viewModel?.sizeItem, viewModel?.usdSizeItem] {
            if tradeInput.options?.needsSize ?? false {
                if let size = tradeInput.size?.size {
                    itemViewModel?.size = dydxFormatter.shared.raw(number: size, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
                } else {
                    itemViewModel?.size = nil
                }
                if let usdcSize = tradeInput.size?.usdcSize {
                    itemViewModel?.usdcSize = dydxFormatter.shared.raw(number: usdcSize, digits: 2)
                } else {
                    itemViewModel?.usdcSize = nil
                }
            }
        }
    }
}
