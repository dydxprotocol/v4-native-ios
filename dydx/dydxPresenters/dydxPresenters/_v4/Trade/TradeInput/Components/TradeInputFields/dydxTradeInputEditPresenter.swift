//
//  dydxTradeInputEditPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 1/4/23.
//

import Abacus
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities
import Combine
import dydxFormatter

internal protocol dydxTradeInputEditViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputEditViewModel? { get }
}

internal class dydxTradeInputEditViewPresenter: HostedViewPresenter<dydxTradeInputEditViewModel>, dydxTradeInputEditViewPresenterProtocol {
    private var tradeInput: TradeInput?
    private var configsAndAsset: MarketConfigsAndAsset?
    private var positionLeverage: Double?
    private var oraclePrice: Double?
    private var isBuy: Bool { tradeInput?.side == .buy }
    private var isSell: Bool { tradeInput?.side == .sell }
    private var marketConfigs: MarketConfigs? { configsAndAsset?.configs }
    private var hasNonZeroSize: Bool { (tradeInput?.size?.size?.doubleValue ?? 0) > 0 || (tradeInput?.size?.usdcSize?.doubleValue ?? 0) > 0 }
    private var hasNonZeroLeverage: Bool { (tradeInput?.size?.leverage?.doubleValue ?? 0) > 0 }
    private var hasNonZeroLimitPrice: Bool { (tradeInput?.price?.limitPrice?.doubleValue ?? 0) > 0 }
    private var hasNonZeroTriggerPrice: Bool { (tradeInput?.price?.triggerPrice?.doubleValue ?? 0) > 0 }
    private var isTriggerPriceGreaterThanOracle: Bool { (tradeInput?.price?.triggerPrice?.doubleValue ?? 0) > (oraclePrice ?? 0) }

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
    private lazy var limitPriceViewModel = dydxTradeInputLimitPriceViewModel(label: DataLocalizer.localize(path: "APP.TRADE.LIMIT_PRICE"), placeHolder: "0.00", onEdited: { [weak self] value in
        guard let self = self else { return }
        self.updateTradeInput(afterChangingField: .limitprice, to: value?.unlocalizedNumericValue, in: self.tradeInput)
        AbacusStateManager.shared.trade(input: value?.unlocalizedNumericValue, type: TradeInputField.limitprice)
    })
    private lazy var triggerPriceViewModel = dydxTradeInputTriggerPriceViewModel(label: DataLocalizer.localize(path: "APP.TRADE.TRIGGER_PRICE"), placeHolder: "0.00", onEdited: { [weak self] value in
        guard let self = self else { return }
        self.updateTradeInput(afterChangingField: .triggerprice, to: value?.unlocalizedNumericValue, in: self.tradeInput)
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
    private let postOnlyViewModel = dydxTradeInputPostOnlyViewModel(label: DataLocalizer.localize(path: "APP.TRADE.POST_ONLY"), onEdited: { value in
        AbacusStateManager.shared.trade(input: value, type: TradeInputField.postonly)
    })
    private let reduceOnlyViewModel = dydxTradeInputReduceOnlyViewModel(label: DataLocalizer.localize(path: "APP.TRADE.REDUCE_ONLY"), onEdited: { value in
        AbacusStateManager.shared.trade(input: value, type: TradeInputField.reduceonly)
    })

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
                    return position?.leverage?.current?.doubleValue
                }
                .removeDuplicates()
                .eraseToAnyPublisher()

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                AbacusStateManager.shared.state.configsAndAssetMap,
                AbacusStateManager.shared.state.marketMap,
                positionLeveragePublisher
            )
            .sink { [weak self] tradeInput, configsAndAsset, marketMap, positionLeverage  in
                if let marketId = tradeInput.marketId {
                    self?.update(tradeInput: tradeInput, configsAndAsset: configsAndAsset[marketId], positionLeverage: positionLeverage, oraclePrice: marketMap[marketId]?.oraclePrice?.doubleValue)
                }
            }
            .store(in: &subscriptions)
    }

    private func getSizeInput() -> PlatformValueInputViewModel? {
        if let size = tradeInput?.size?.size {
            sizeViewModel.size = dydxFormatter.shared.raw(number: size, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
        } else {
            sizeViewModel.size = nil
        }
        if let usdcSize = tradeInput?.size?.usdcSize {
            sizeViewModel.usdcSize = dydxFormatter.shared.raw(number: usdcSize, digits: 2)
        } else {
            sizeViewModel.usdcSize = nil
        }
        sizeViewModel.tokenSymbol = configsAndAsset?.asset?.id ?? configsAndAsset?.assetId
        return sizeViewModel
    }

    private func getLeverageInput() -> PlatformValueInputViewModel? {
        guard !hasNonZeroLimitPrice && !hasNonZeroTriggerPrice else { return nil }
        if let side = tradeInput?.side {
            switch side {
            case .buy:
                leverageViewModel.tradeSide = .BUY
            case .sell:
                leverageViewModel.tradeSide = .SELL
            default:
                break
            }
        }
        if let leverage = tradeInput?.size?.leverage?.doubleValue {
            leverageViewModel.leverage = leverage
        }
        leverageViewModel.maxLeverage = tradeInput?.options?.maxLeverage?.doubleValue ?? 10
        leverageViewModel.positionLeverage = positionLeverage ?? 0
        return leverageViewModel
    }

    private func getLimitPriceInput() -> PlatformValueInputViewModel? {
        guard hasNonZeroSize else { return nil }
        if let limitPrice = tradeInput?.price?.limitPrice {
            limitPriceViewModel.value = dydxFormatter.shared.raw(number: limitPrice, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 2)
        } else {
            limitPriceViewModel.value = nil
        }
        return limitPriceViewModel
    }

    private func getTriggerPriceInput() -> PlatformValueInputViewModel? {
        guard hasNonZeroSize else { return nil }
        if let triggerPrice = tradeInput?.price?.triggerPrice {
            triggerPriceViewModel.value = dydxFormatter.shared.raw(number: triggerPrice, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 2)
        } else {
            triggerPriceViewModel.value = nil
        }
        return triggerPriceViewModel
    }

    private func getTimeInForceInput() -> PlatformValueInputViewModel? {
        var options = [InputSelectOption]()
        for timeInForce in tradeInput?.options?.timeInForceOptions ?? [] {
            let string = timeInForce.string ?? DataLocalizer.shared?.localize(path: timeInForce.stringKey ?? "", params: nil) ?? ""
            options.append(InputSelectOption(value: timeInForce.type, string: string))
        }
        timeInForceViewModel.options = options
        timeInForceViewModel.value = tradeInput?.timeInForce
        return timeInForceViewModel
    }

    private func getGoodUntilInput() -> PlatformValueInputViewModel? {
        if let goodUntilUnitOptions = tradeInput?.options?.goodTilUnitOptions {
            goodTilViewModel.unit?.options = AbacusUtils.translate(options: goodUntilUnitOptions)
            goodTilViewModel.unit?.value = tradeInput?.goodTil?.unit
            return goodTilViewModel
        }
        if let duration = tradeInput?.goodTil?.duration?.intValue {
            goodTilViewModel.duration?.value = "\(duration)"
        } else {
            goodTilViewModel.duration?.value = nil
        }
        return nil
    }

    private func getExecutionInput() -> PlatformValueInputViewModel? {
        if let executionOptions = tradeInput?.options?.executionOptions {
            executionViewModel.options = AbacusUtils.translate(options: executionOptions)
            executionViewModel.value = tradeInput?.execution
            return executionViewModel
        } else {
            return nil
        }
    }

    private func getReduceOnly() -> PlatformValueInputViewModel? {
        reduceOnlyViewModel.isEnabled = tradeInput?.options?.needsReduceOnly == true
        reduceOnlyViewModel.value = (tradeInput?.reduceOnly == true) ? "true" : "false"
        return reduceOnlyViewModel
    }

    private func getPostOnly() -> PlatformValueInputViewModel? {
        postOnlyViewModel.isEnabled = tradeInput?.options?.needsPostOnly == true
        postOnlyViewModel.value = (tradeInput?.postOnly == true) ? "true" : "false"
        return postOnlyViewModel
    }

    private func update(tradeInput: TradeInput, configsAndAsset: MarketConfigsAndAsset?, positionLeverage: Double?, oraclePrice: Double?) {
        self.tradeInput = tradeInput
        self.configsAndAsset = configsAndAsset
        self.positionLeverage = positionLeverage
        self.oraclePrice = oraclePrice

        sizeViewModel.placeHolder = dydxFormatter.shared.raw(number: 0, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 0)
        limitPriceViewModel.placeHolder = dydxFormatter.shared.raw(number: 0, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 0)
        triggerPriceViewModel.placeHolder = dydxFormatter.shared.raw(number: 0, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.children = [
            getSizeInput(),
            getLeverageInput(),
            getLimitPriceInput(),
            getTriggerPriceInput()
        ].compactMap { $0 }

        let isMarketOrder =             hasNonZeroSize && !hasNonZeroLimitPrice && !hasNonZeroTriggerPrice
        let isLimitOrder =              hasNonZeroSize && hasNonZeroLimitPrice && !hasNonZeroTriggerPrice
        let isStopLimitOrder =          hasNonZeroSize && hasNonZeroLimitPrice && hasNonZeroTriggerPrice && (isTriggerPriceGreaterThanOracle && isBuy || !isTriggerPriceGreaterThanOracle && isSell)
        let isStopMarketOrder =         hasNonZeroSize && !hasNonZeroLimitPrice && hasNonZeroTriggerPrice && (isTriggerPriceGreaterThanOracle && isBuy || !isTriggerPriceGreaterThanOracle && isSell)
        let isTakeProfitLimitOrder =    hasNonZeroSize && hasNonZeroLimitPrice && hasNonZeroTriggerPrice && (!isTriggerPriceGreaterThanOracle && isBuy || isTriggerPriceGreaterThanOracle && isSell)
        let isTakeProfitMarketOrder =   hasNonZeroSize && !hasNonZeroLimitPrice && hasNonZeroTriggerPrice && (!isTriggerPriceGreaterThanOracle && isBuy || isTriggerPriceGreaterThanOracle && isSell)

        if isMarketOrder {
            AbacusStateManager.shared.trade(input: OrderType.market.rawValue, type: TradeInputField.type)
        } else if isLimitOrder {
            AbacusStateManager.shared.trade(input: OrderType.limit.rawValue, type: TradeInputField.type)
        } else if isStopLimitOrder {
            AbacusStateManager.shared.trade(input: OrderType.stoplimit.rawValue, type: TradeInputField.type)
        } else if isStopMarketOrder {
            AbacusStateManager.shared.trade(input: OrderType.stopmarket.rawValue, type: TradeInputField.type)
        } else if isTakeProfitLimitOrder {
            AbacusStateManager.shared.trade(input: OrderType.takeprofitlimit.rawValue, type: TradeInputField.type)
        } else if isTakeProfitMarketOrder {
            AbacusStateManager.shared.trade(input: OrderType.takeprofitmarket.rawValue, type: TradeInputField.type)
        }
    }

    private func updateTradeInput(afterChangingField field: TradeInputField, to value: String?, in tradeInput: TradeInput?) {
        guard let value = value,
              let value = Double(value),
              let tradeInput = tradeInput else {
            return
        }

        let newTradeInput: TradeInput
        switch field {
        case .size:
            newTradeInput = .init(type: tradeInput.type,
                                    side: tradeInput.side,
                                    marketId: tradeInput.marketId,
                                    size: .init(size: .init(double: value), usdcSize: tradeInput.size?.usdcSize, leverage: tradeInput.size?.leverage, input: tradeInput.size?.input),
                                    price: tradeInput.price,
                                    timeInForce: tradeInput.timeInForce,
                                    goodTil: tradeInput.goodTil,
                                    execution: tradeInput.execution,
                                    reduceOnly: tradeInput.reduceOnly,
                                    postOnly: tradeInput.postOnly,
                                    fee: tradeInput.fee,
                                    bracket: tradeInput.bracket,
                                    marketOrder: tradeInput.marketOrder,
                                    options: tradeInput.options,
                                    summary: tradeInput.summary)

        case .usdcsize:
            newTradeInput = .init(type: tradeInput.type,
                                    side: tradeInput.side,
                                    marketId: tradeInput.marketId,
                                    size: .init(size: tradeInput.size?.size, usdcSize: .init(double: value), leverage: tradeInput.size?.leverage, input: tradeInput.size?.input),
                                    price: tradeInput.price,
                                    timeInForce: tradeInput.timeInForce,
                                    goodTil: tradeInput.goodTil,
                                    execution: tradeInput.execution,
                                    reduceOnly: tradeInput.reduceOnly,
                                    postOnly: tradeInput.postOnly,
                                    fee: tradeInput.fee,
                                    bracket: tradeInput.bracket,
                                    marketOrder: tradeInput.marketOrder,
                                    options: tradeInput.options,
                                    summary: tradeInput.summary)
        case .triggerprice:
            newTradeInput = .init(type: tradeInput.type,
                                    side: tradeInput.side,
                                    marketId: tradeInput.marketId,
                                    size: tradeInput.size,
                                    price: .init(limitPrice: tradeInput.price?.limitPrice, triggerPrice: .init(double: value), trailingPercent: tradeInput.price?.trailingPercent),
                                    timeInForce: tradeInput.timeInForce,
                                    goodTil: tradeInput.goodTil,
                                    execution: tradeInput.execution,
                                    reduceOnly: tradeInput.reduceOnly,
                                    postOnly: tradeInput.postOnly,
                                    fee: tradeInput.fee,
                                    bracket: tradeInput.bracket,
                                    marketOrder: tradeInput.marketOrder,
                                    options: tradeInput.options,
                                    summary: tradeInput.summary)
        case .limitprice:
            newTradeInput = .init(type: tradeInput.type,
                                    side: tradeInput.side,
                                    marketId: tradeInput.marketId,
                                    size: tradeInput.size,
                                    price: .init(limitPrice: .init(double: value), triggerPrice: tradeInput.price?.triggerPrice, trailingPercent: tradeInput.price?.trailingPercent),
                                    timeInForce: tradeInput.timeInForce,
                                    goodTil: tradeInput.goodTil,
                                    execution: tradeInput.execution,
                                    reduceOnly: tradeInput.reduceOnly,
                                    postOnly: tradeInput.postOnly,
                                    fee: tradeInput.fee,
                                    bracket: tradeInput.bracket,
                                    marketOrder: tradeInput.marketOrder,
                                    options: tradeInput.options,
                                    summary: tradeInput.summary)
        default:
            return
        }
        update(tradeInput: newTradeInput, configsAndAsset: configsAndAsset, positionLeverage: positionLeverage, oraclePrice: oraclePrice)
    }
}
