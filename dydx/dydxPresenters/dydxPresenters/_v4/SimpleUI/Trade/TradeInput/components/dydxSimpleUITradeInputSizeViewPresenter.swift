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
        let item = dydxSimpleUITradeInputSizeItemViewModel(label: nil, placeHolder: "0.000  ", onEdited: { value in
                AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue,
                                                type: TradeInputField.size)
        })
        item.showingUsdc = false
        return item
    }()

    private lazy var closePositionSizeItem: dydxSimpleUITradeInputSizeItemViewModel = {
        let item = dydxSimpleUITradeInputSizeItemViewModel(label: nil, placeHolder: "0.000  ", onEdited: { value in
            AbacusStateManager.shared.closePosition(input: value?.unlocalizedNumericValue,
                                                    type: ClosePositionInputField.size)
        })
        item.showingUsdc = false
        return item
    }()

    private lazy var usdcSizeItem: dydxSimpleUITradeInputSizeItemViewModel = {
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
        options.append(InputSelectOption(value: "0.25", string: "25%"))
        options.append(InputSelectOption(value: "0.50", string: "50%"))
        options.append(InputSelectOption(value: "0.75", string: "75%"))
        options.append(InputSelectOption(value: "1.0", string: DataLocalizer.localize(path: "APP.GENERAL.FULL_CLOSE")))

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
        viewModel?.usdcSizeItem = usdcSizeItem
        viewModel?.closePositionSizeItem = closePositionSizeItem
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
                AbacusStateManager.shared.state.closePositionInput
            )
            .map { ($0, $1, $2) }
            .eraseToAnyPublisher()

        Publishers
            .CombineLatest3(
                inputsPublisher,
                AbacusStateManager.shared.state.configsAndAssetMap,
                viewModel.$focusState
            )
            .sink { [weak self] inputs, configsAndAssetMap, focusState in
                guard let self else { return }
                let (tradeType, tradeInput, closePositionInput) = inputs

                let marketId: String?
                let size: Double?
                let usdcSize: Double?

                switch tradeType {
                case .trade:
                    marketId = tradeInput?.marketId
                    if marketId == nil {
                        return
                    }
                    size = tradeInput?.size?.size?.doubleValue
                    usdcSize = tradeInput?.size?.usdcSize?.doubleValue
                    if focusState == dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                        self.updateFocusState(.atUsdcSize)
                    }
                    self.viewModel?.percent = nil
                case .closePosition:
                    marketId = closePositionInput?.marketId
                    if marketId == nil {
                        return
                    }
                    size = closePositionInput?.size?.size?.doubleValue
                    usdcSize = closePositionInput?.size?.usdcSize?.doubleValue
                    if parser.asNumber(self.percent.value)?.doubleValue != closePositionInput?.size?.percent?.doubleValue {
                        self.percent.value = parser.asString(closePositionInput?.size?.percent?.doubleValue)
                    }
                    if focusState == dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                        self.updateFocusState(.atClosePosition)
                    }
                    self.viewModel?.percent = self.percent
                }

                if let marketId {
                    self.update(tradeType: tradeType,
                                size: size,
                                usdcSize: usdcSize,
                                configsAndAsset: configsAndAssetMap[marketId],
                                focusState: focusState)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(tradeType: TradeSubmission.TradeType,
                        size: Double?,
                        usdcSize: Double?,
                        configsAndAsset: MarketConfigsAndAsset?,
                        focusState: dydxSimpleUITradeInputSizeViewModel.FocusState) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        let stepSize = marketConfigs?.displayStepSizeDecimals?.intValue ?? 0
        let placeHolder = dydxFormatter.shared.raw(number: .zero, digits: stepSize) ?? ""
        viewModel?.sizeItem?.placeHolder = placeHolder
        viewModel?.sizeItem?.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id
        viewModel?.closePositionSizeItem?.placeHolder = placeHolder
        viewModel?.closePositionSizeItem?.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id
        viewModel?.usdcSizeItem?.placeHolder = "0.000"
        viewModel?.usdcSizeItem?.tokenSymbol = "USD"

        let items: [dydxSimpleUITradeInputSizeItemViewModel?]
        switch tradeType {
        case .trade:
            items = [viewModel?.sizeItem, viewModel?.usdcSizeItem]
        case .closePosition:
            items = [viewModel?.closePositionSizeItem]
        }
        for itemViewModel in items {
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
            viewModel?.secondaryText = viewModel?.usdcSizeItem?.usdcSize ?? viewModel?.usdcSizeItem?.placeHolder
            viewModel?.secondaryToken = viewModel?.usdcSizeItem?.tokenSymbol
        case .atUsdcSize, .none:
            viewModel?.secondaryText = viewModel?.sizeItem?.size ?? viewModel?.sizeItem?.placeHolder
            viewModel?.secondaryToken = viewModel?.sizeItem?.tokenSymbol
        case .atClosePosition:
            viewModel?.secondaryText = viewModel?.closePositionSizeItem?.usdcSize ?? viewModel?.closePositionSizeItem?.placeHolder
            viewModel?.secondaryToken = "USD"
        }
    }
}
