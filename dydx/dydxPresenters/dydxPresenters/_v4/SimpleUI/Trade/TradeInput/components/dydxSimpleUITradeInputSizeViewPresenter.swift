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
    @Published var tradeType: TradeSubmission.TradeType = .trade

    private lazy var sizeItem: dydxSimpleUITradeInputSizeItemViewModel = {
        let item = dydxSimpleUITradeInputSizeItemViewModel(label: nil, placeHolder: "0.000", onEdited: { value in
            switch self.tradeType {
            case .trade:
                AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue,
                                                type: TradeInputField.size)
            case .closePosition:
                AbacusStateManager.shared.closePosition(input: value?.unlocalizedNumericValue,
                                                        type: ClosePositionInputField.size)
            }

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

    private lazy var percent: dydxSimpleUIClosePercentViewModel = {
        var options = [InputSelectOption]()
        // must be 1.0 so that when double value is parsed as string, it matches for 1
        options.append(InputSelectOption(value: "1.0", string: "100%"))
        options.append(InputSelectOption(value: "0.50", string: "50%"))
        options.append(InputSelectOption(value: "0.25", string: "25%"))

        let item = dydxSimpleUIClosePercentViewModel()
        item.options = options
        item.onEdited = { value in
            PlatformView.hideKeyboard()
            AbacusStateManager.shared.closePosition(input: value, type: ClosePositionInputField.percent)
        }
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

        let inputsPublisher = Publishers
            .CombineLatest3(
                $tradeType,
            AbacusStateManager.shared.state.tradeInput,
            AbacusStateManager.shared.state.closePositionInput)
            .map { ($0, $1, $2) }
            .eraseToAnyPublisher()

        Publishers
            .CombineLatest3(
                inputsPublisher,
                AbacusStateManager.shared.state.configsAndAssetMap,
                viewModel.$focusState)
            .sink { [weak self] inputs, configsAndAssetMap, focusState in
                guard let self else { return }
                let (tradeType, tradeInput, closePositionInput) = inputs

                let marketId: String?
                let size: Double?
                let usdcSize: Double?

                switch tradeType {
                case .trade:
                    marketId = tradeInput?.marketId
                    size = tradeInput?.size?.size?.doubleValue
                    usdcSize = tradeInput?.size?.usdcSize?.doubleValue
                    if focusState == dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                        self.updateFocusState(.atUsdcSize)
                    }
                    self.viewModel?.percent = nil
                case .closePosition:
                    marketId = closePositionInput?.marketId
                    size = closePositionInput?.size?.size?.doubleValue
                    usdcSize = closePositionInput?.size?.usdcSize?.doubleValue
                    if focusState == dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                        self.updateFocusState(.atSize)
                    }
                    if parser.asNumber(self.percent.value)?.doubleValue != closePositionInput?.size?.percent?.doubleValue {
                        self.percent.value = parser.asString(closePositionInput?.size?.percent?.doubleValue)
                    }
                    self.viewModel?.percent = self.percent
                }

                if let marketId {
                    self.update(size: size,
                                usdcSize: usdcSize,
                                configsAndAsset: configsAndAssetMap[marketId],
                                focusState: focusState)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(size: Double?,
                        usdcSize: Double?,
                        configsAndAsset: MarketConfigsAndAsset?,
                        focusState: dydxSimpleUITradeInputSizeViewModel.FocusState) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        viewModel?.sizeItem?.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
        viewModel?.sizeItem?.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id
        viewModel?.usdSizeItem?.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: 3)
        viewModel?.usdSizeItem?.tokenSymbol = "USD"

        for itemViewModel in [viewModel?.sizeItem, viewModel?.usdSizeItem] {
            if let size = size {
                itemViewModel?.size = dydxFormatter.shared.raw(number: size, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
            } else {
                itemViewModel?.size = nil
            }
            if let usdcSize = usdcSize {
                itemViewModel?.usdcSize = dydxFormatter.shared.raw(number: usdcSize, digits: 2)
            } else {
                itemViewModel?.usdcSize = nil
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
