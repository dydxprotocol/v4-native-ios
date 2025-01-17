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
        viewModel?.focusState = .none
    }

    private func updateFocusState(_ focusState: dydxSimpleUITradeInputSizeViewModel.FocusState) {
        viewModel?.focusState = focusState
    }

    override func start() {
        super.start()

        guard let viewModel else { return }

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.tradeInput
                    .compactMap { $0 }
                    .removeDuplicates(),
                AbacusStateManager.shared.state.configsAndAssetMap,
                viewModel.$focusState)
            .sink { [weak self] tradeInput, configsAndAssetMap, focusState in
                if let marketId = tradeInput.marketId {
                    self?.update(tradeInput: tradeInput,
                                 configsAndAsset: configsAndAssetMap[marketId],
                                 focusState: focusState)
                    if focusState == dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                        self?.updateFocusState(.atUsdcSize)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput,
                        configsAndAsset: MarketConfigsAndAsset?,
                        focusState: dydxSimpleUITradeInputSizeViewModel.FocusState) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        viewModel?.sizeItem?.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
        viewModel?.sizeItem?.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id
        viewModel?.usdSizeItem?.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: 3)
        viewModel?.usdSizeItem?.tokenSymbol = "USD"

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

        switch focusState {
        case .atSize:
            viewModel?.secondaryText = viewModel?.usdSizeItem?.usdcSize ?? viewModel?.usdSizeItem?.placeHolder
            viewModel?.secondaryToken = viewModel?.usdSizeItem?.tokenSymbol
        case .atUsdcSize, .none:
            viewModel?.secondaryText = viewModel?.sizeItem?.size ?? viewModel?.sizeItem?.placeHolder
            viewModel?.secondaryToken = viewModel?.sizeItem?.tokenSymbol
        }
    }
}
