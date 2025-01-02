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

    override init() {
        super.init()

        viewModel = dydxSimpleUITradeInputSizeViewModel(label: nil, placeHolder: "0.000") { [weak self] value in
            if let vm = self?.viewModel {
                AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue, type: vm.showingUsdc ? TradeInputField.usdcsize : TradeInputField.size)
            }
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
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

        viewModel?.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)

        if tradeInput.options?.needsSize ?? false {
            if let size = tradeInput.size?.size {
                viewModel?.size = dydxFormatter.shared.raw(number: size, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
            } else {
                viewModel?.size = nil
            }
            if let usdcSize = tradeInput.size?.usdcSize {
                viewModel?.usdcSize = dydxFormatter.shared.raw(number: usdcSize, digits: 2)
            } else {
                viewModel?.usdcSize = nil
            }
            viewModel?.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id
        }
    }
}
