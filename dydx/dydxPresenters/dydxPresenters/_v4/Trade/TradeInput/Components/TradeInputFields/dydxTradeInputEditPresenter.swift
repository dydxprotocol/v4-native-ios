//
//  dydxTradeInputEditPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 1/4/23.
//

import Abacus
import Combine
import dydxFormatter
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities

internal protocol dydxTradeInputEditViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputEditViewModel? { get }
}

internal class dydxTradeInputEditViewPresenter: HostedViewPresenter<dydxTradeInputEditViewModel>, dydxTradeInputEditViewPresenterProtocol {
    private lazy var sizeViewModel: dydxTradeInputSizeViewModel = {
        let viewModel = dydxTradeInputSizeViewModel(label: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"), placeHolder: "0.000") { [weak self] value in
            if let vm = self?.sizeViewModel {
                AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue, type: vm.showingUsdc ? TradeInputField.usdcsize : TradeInputField.size)
            }
        }
        return viewModel
    }()

    private lazy var leverageViewModel: dydxTradeInputLeverageViewModel = {
        let viewModel = dydxTradeInputLeverageViewModel(label: DataLocalizer.localize(path: "APP.GENERAL.LEVERAGE"),
                                                        placeHolder: "0.00")
        viewModel.onEdited = { [weak self] value in
            guard let value = value?.unlocalizedNumericValue else {
                return
            }
            AbacusStateManager.shared.trade(input: value, type: TradeInputField.leverage)
        }
        return viewModel
    }()

    private let limitPriceViewModel = dydxTradeInputLimitPriceViewModel(label: DataLocalizer.localize(path: "APP.TRADE.LIMIT_PRICE"), placeHolder: "0.00", onEdited: { value in
        AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue, type: TradeInputField.limitprice)
    })
    private let triggerPriceViewModel = dydxTradeInputTriggerPriceViewModel(label: DataLocalizer.localize(path: "APP.TRADE.TRIGGER_PRICE"), placeHolder: "0.00", onEdited: { value in
        AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue, type: TradeInputField.triggerprice)
    })
    private let trailingPercentViewModel = dydxTradeInputTrailingPercentViewModel(label: DataLocalizer.localize(path: "APP.TRADE.TRAILING_PERCENT"), onEdited: { value in
        if let numeric = Parser.standard.asNumber(value?.unlocalizedNumericValue?.replacingOccurrences(of: "%", with: ""))?.doubleValue {
            AbacusStateManager.shared.trade(input: Parser.standard.asString(numeric / 100.0), type: TradeInputField.trailingpercent)
        } else {
            AbacusStateManager.shared.trade(input: nil, type: TradeInputField.trailingpercent)
        }
    })
    private let timeInForceViewModel = dydxTradeInputTimeInForceViewModel(label: DataLocalizer.localize(path: "APP.TRADE.TIME_IN_FORCE"), onEdited: { value in
        AbacusStateManager.shared.trade(input: value, type: TradeInputField.timeinforcetype)
    })
    private let goodTilDurationViewModel = dydxTradeInputGoodTilDurationViewModel(label: DataLocalizer.localize(path: "APP.TRADE.GOOD_TIL"), onEdited: { value in
        AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue, type: TradeInputField.goodtilduration)
    })
    private let goodTilUnitViewModel = dydxTradeInputGoodTilUnitViewModel(onEdited: { value in
        AbacusStateManager.shared.trade(input: value, type: TradeInputField.goodtilunit)
    })
    private lazy var goodTilViewModel = dydxTradeInputGoodTilViewModel(duration: goodTilDurationViewModel, unit: goodTilUnitViewModel)
    private let executionViewModel = dydxTradeInputExecutionViewModel(label: DataLocalizer.localize(path: "APP.TRADE.EXECUTION"), onEdited: { value in
        AbacusStateManager.shared.trade(input: value, type: TradeInputField.execution)
    })
    private func postOnlyViewModel() -> dydxTradeInputPostOnlyViewModel {
        return dydxTradeInputPostOnlyViewModel(label: DataLocalizer.localize(path: "APP.TRADE.POST_ONLY"), onEdited: { value in
            AbacusStateManager.shared.trade(input: value, type: TradeInputField.postonly)
        })
    }

    private func reduceOnlyViewModel() -> dydxTradeInputReduceOnlyViewModel {
        return dydxTradeInputReduceOnlyViewModel(label: DataLocalizer.localize(path: "APP.TRADE.REDUCE_ONLY"), onEdited: { value in
            AbacusStateManager.shared.trade(input: value, type: TradeInputField.reduceonly)
        })
    }

    private var orderTypeRequiresLimitPrice: Bool = false

    override init() {
        super.init()

        viewModel = dydxTradeInputEditViewModel()
    }

    override func start() {
        super.start()

        let positionLeveragePublisher: AnyPublisher<Double?, Never> =
            Publishers
                .CombineLatest(
                    AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                    AbacusStateManager.shared.state.selectedSubaccountPositions)
                .map { (tradeInput: TradeInput, positions: [SubaccountPosition]) -> Double? in
                    guard let marketId = tradeInput.marketId else {
                        return nil
                    }
                    let position: SubaccountPosition? = positions.first { $0.id == marketId }
                    return position?.leverage.current?.doubleValue
                }
                .removeDuplicates()
                .eraseToAnyPublisher()

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                AbacusStateManager.shared.state.configsAndAssetMap,
                positionLeveragePublisher)
            .sink { [weak self] tradeInput, configsAndAssetMap, positionLeverage in
                if let marketId = tradeInput.marketId {
                    self?.update(tradeInput: tradeInput, configsAndAsset: configsAndAssetMap[marketId], positionLeverage: positionLeverage)
                }
            }
            .store(in: &subscriptions)
    }

    private func updateOrderTypeRequiresLimitPrice(forOrderType orderType: Abacus.OrderType?) {
        if let orderType {
            switch orderType {
            case .limit, .stoplimit, .takeprofitlimit:
                orderTypeRequiresLimitPrice = true
            default:
                orderTypeRequiresLimitPrice = false
            }
        } else {
            orderTypeRequiresLimitPrice = false
        }
    }

    private func update(tradeInput: TradeInput, configsAndAsset: MarketConfigsAndAsset?, positionLeverage: Double?) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        var visible = [PlatformValueInputViewModel]()

        sizeViewModel.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
        limitPriceViewModel.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 0)
        triggerPriceViewModel.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 0)

        updateOrderTypeRequiresLimitPrice(forOrderType: tradeInput.type)

        if tradeInput.options?.needsSize ?? false {
            if let size = tradeInput.size?.size {
                sizeViewModel.size = dydxFormatter.shared.raw(number: size, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
            } else {
                sizeViewModel.size = nil
            }
            if let usdcSize = tradeInput.size?.usdcSize {
                sizeViewModel.usdcSize = dydxFormatter.shared.raw(number: usdcSize, digits: 2)
            } else {
                sizeViewModel.usdcSize = nil
            }
            sizeViewModel.tokenSymbol = configsAndAsset?.asset?.displayableAssetId ?? asset?.id
            visible.append(sizeViewModel)

            if tradeInput.options?.needsLeverage ?? false {
                if let side = tradeInput.side {
                    switch side {
                    case .buy:
                        leverageViewModel.tradeSide = .BUY
                    case .sell:
                        leverageViewModel.tradeSide = .SELL
                    default:
                        break
                    }
                }
                if let leverage = tradeInput.size?.leverage?.doubleValue {
                    leverageViewModel.leverage = leverage
                }
                leverageViewModel.maxLeverage = tradeInput.options?.maxLeverage?.doubleValue ?? 10
                leverageViewModel.positionLeverage = positionLeverage ?? 0
                visible.append(leverageViewModel)
            }
        }
        if tradeInput.options?.needsLimitPrice ?? false {
            if let limitPrice = tradeInput.price?.limitPrice {
                limitPriceViewModel.value = dydxFormatter.shared.raw(number: limitPrice, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 2)
            } else {
                limitPriceViewModel.value = nil
            }
            visible.append(limitPriceViewModel)
        }
        if tradeInput.options?.needsTriggerPrice ?? false {
            if let triggerPrice = tradeInput.price?.triggerPrice {
                triggerPriceViewModel.value = dydxFormatter.shared.raw(number: triggerPrice, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 2)
            } else {
                triggerPriceViewModel.value = nil
            }
            visible.append(triggerPriceViewModel)
        }
        if tradeInput.options?.needsTrailingPercent ?? false {
            if let trailingPercent = tradeInput.price?.trailingPercent?.doubleValue {
                trailingPercentViewModel.value = dydxFormatter.shared.percent(number: trailingPercent, digits: 0)
            } else {
                trailingPercentViewModel.value = nil
            }
            visible.append(trailingPercentViewModel)
        }
        if let timeInForceOptions = tradeInput.options?.timeInForceOptions {
            var options = [InputSelectOption]()
            for timeInForce in timeInForceOptions {
                let string = timeInForce.string ?? DataLocalizer.shared?.localize(path: timeInForce.stringKey ?? "", params: nil) ?? ""
                options.append(InputSelectOption(value: timeInForce.type, string: string))
            }
            timeInForceViewModel.options = options
            timeInForceViewModel.value = tradeInput.timeInForce
            visible.append(timeInForceViewModel)
        }
        if tradeInput.options?.needsGoodUntil ?? false {
            if let goodUntilUnitOptions = tradeInput.options?.goodTilUnitOptions {
                goodTilViewModel.unit?.options = AbacusUtils.translate(options: goodUntilUnitOptions)
                goodTilViewModel.unit?.value = tradeInput.goodTil?.unit
                visible.append(goodTilViewModel)
            }
            if let duration = tradeInput.goodTil?.duration?.intValue {
                goodTilViewModel.duration?.value = "\(duration)"
            } else {
                goodTilViewModel.duration?.value = nil
            }
        }
        if let executionOptions = tradeInput.options?.executionOptions {
            executionViewModel.options = AbacusUtils.translate(options: executionOptions)
            executionViewModel.value = tradeInput.execution
            visible.append(executionViewModel)
        }

        if tradeInput.options?.needsReduceOnly == true {
            let vm = reduceOnlyViewModel()
            vm.isEnabled = tradeInput.options?.needsReduceOnly == true
            vm.value = (tradeInput.reduceOnly == true) ? "true" : "false"
            visible.append(vm)
        }

        if tradeInput.options?.needsPostOnly == true {
            let vm = postOnlyViewModel()
            vm.isEnabled = tradeInput.options?.needsPostOnly == true
            vm.value = (tradeInput.postOnly == true) ? "true" : "false"
            visible.append(vm)
        }

        viewModel?.children = visible
    }
}

extension dydxTradeInputEditViewPresenter: dydxOrderbookSideDelegate {
    func onPriceSelected(price: Double) {
        guard orderTypeRequiresLimitPrice else { return }
        AbacusStateManager.shared.trade(input: "\(price)", type: TradeInputField.limitprice)
    }
}
