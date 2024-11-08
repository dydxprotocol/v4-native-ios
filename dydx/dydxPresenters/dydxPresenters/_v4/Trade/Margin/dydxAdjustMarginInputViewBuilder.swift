//
//  dydxAdjustMarginInputViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 08/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import dydxFormatter

public class dydxAdjustMarginInputViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxAdjustMarginInputViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxAdjustMarginInputViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxAdjustMarginInputViewController: HostingViewController<PlatformView, dydxAdjustMarginInputViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/adjust_margin",
            let marketId = parser.asString(request?.params?["marketId"]),
            let childSubaccountNumber = parser.asString(request?.params?["childSubaccountNumber"]) {
            let presenter = presenter as? dydxAdjustMarginInputViewPresenterProtocol
            presenter?.childSubaccountNumber = childSubaccountNumber
            presenter?.marketId = marketId
            return true
        }
        return false
    }
}

private protocol dydxAdjustMarginInputViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAdjustMarginInputViewModel? { get }
    var marketId: String? { get set }
    var childSubaccountNumber: String? { get set }
}

private class dydxAdjustMarginInputViewPresenter: HostedViewPresenter<dydxAdjustMarginInputViewModel>, dydxAdjustMarginInputViewPresenterProtocol {
    private let ctaButtonPresenter = dydxAdjustMarginCtaButtonViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        ctaButtonPresenter
    ]

    var marketId: String?
    var childSubaccountNumber: String?

    private let percentageOptions: [dydxAdjustMarginPercentageViewModel.PercentageOption] = [
        .init(text: "5%", percentage: 0.05),
        .init(text: "10%", percentage: 0.10),
        .init(text: "25%", percentage: 0.25),
        .init(text: "50%", percentage: 0.50),
        .init(text: "75%", percentage: 0.75)
    ]

    override init() {
        let viewModel = dydxAdjustMarginInputViewModel()

        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButton)

        super.init()

        viewModel.marginDirection?.marginDirectionAction = { direction in
            AbacusStateManager.shared.adjustIsolatedMargin(input: direction.rawValue, type: .type)
        }

        viewModel.marginPercentage?.percentageOptions = percentageOptions
        viewModel.marginPercentage?.percentageOptionSelectedAction = { option in
            AbacusStateManager.shared.adjustIsolatedMargin(input: option.percentage.stringValue, type: .amountpercent)
        }
        viewModel.amount?.onEdited = { amount in
            AbacusStateManager.shared.adjustIsolatedMargin(input: amount, type: .amount)
        }

        ctaButtonPresenter.viewModel?.ctaAction = { [weak self] in
            self?.ctaButtonPresenter.viewModel?.ctaButtonState = .thinking
            AbacusStateManager.shared.commitAdjustIsolatedMargin { [weak self] (_, error, _) in
                self?.ctaButtonPresenter.viewModel?.ctaButtonState = .disabled()
                if let error = error {
                    self?.viewModel?.inlineAlert = InlineAlertViewModel(.init(title: nil, body: error.localizedMessage, level: .error))
                    return
                } else {
                    self?.resetInputAmount()
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
                }
            }
        }

        viewModel.amount?.placeHolder = dydxFormatter.shared.dollar(number: 0.0, digits: 2)

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    private func resetInputAmount() {
        AbacusStateManager.shared.adjustIsolatedMargin(input: nil, type: .amount)
    }

    override func start() {
        super.start()
        guard let marketId, let childSubaccountNumber else { return }

        AbacusStateManager.shared.setMarket(market: marketId)
        AbacusStateManager.shared.adjustIsolatedMargin(input: marketId, type: .market)
        AbacusStateManager.shared.adjustIsolatedMargin(input: childSubaccountNumber, type: .childsubaccountnumber)

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.market(of: marketId).compactMap { $0 },
                AbacusStateManager.shared.state.assetMap,
                AbacusStateManager.shared.state.adjustIsolatedMarginInput.compactMap { $0 },
                AbacusStateManager.shared.state.selectedSubaccountPositions.compactMap { $0.first(where: { $0.id == marketId }) }
            )
            .sink { [weak self] market, assetMap, input, position in
                self?.updateState(market: market, assetMap: assetMap)
                self?.updateFields(input: input)
                self?.updateForMarginDirection(input: input)
                self?.updatePrePostValues(input: input, market: market)
                guard let side = position.side.current else { return }
                self?.updateLiquidationPrice(input: input, side: side, market: market)
            }
            .store(in: &subscriptions)
    }

    private func updateState(market: PerpetualMarket, assetMap: [String: Asset]) {
        let asset = assetMap[market.assetId]
        viewModel?.sharedMarketViewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
    }

    private func updateForMarginDirection(input: AdjustIsolatedMarginInput) {

        switch input.type {
        case IsolatedMarginAdjustmentType.add:
            viewModel?.marginDirection?.marginDirection = .add
            viewModel?.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT_TO_ADD")
        case IsolatedMarginAdjustmentType.remove:
            viewModel?.marginDirection?.marginDirection = .remove
            viewModel?.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT_TO_REMOVE")
        default:
            viewModel?.marginDirection?.marginDirection = .add
            viewModel?.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT")
        }
    }

    // TODO: move this to abacus
    /// locally validates the input
    /// - Parameter input: input to validate
    /// - Returns: the localization error string key if invalid input
    private func validate(input: AdjustIsolatedMarginInput, market: PerpetualMarket) -> String? {
        guard let amount = parser.asNumber(input.amount)?.doubleValue else { return nil }
        switch input.type {
        case IsolatedMarginAdjustmentType.add:
            if let crossFreeCollateral = input.summary?.crossFreeCollateral?.doubleValue, amount >= crossFreeCollateral {
                return "ERRORS.TRANSFER_MODAL.TRANSFER_MORE_THAN_FREE"
            }
            if let crossMarginUsageUpdated = input.summary?.crossMarginUsageUpdated?.doubleValue, crossMarginUsageUpdated > 1 {
                return "ERRORS.TRADE_BOX.INVALID_NEW_ACCOUNT_MARGIN_USAGE"
            }
        case IsolatedMarginAdjustmentType.remove:
            if let effectiveInitialMarginFraction = market.configs?.effectiveInitialMarginFraction?.doubleValue, effectiveInitialMarginFraction > 0 {
                let marketMaxLeverage = 1 / effectiveInitialMarginFraction
                if let positionLeverageUpdated = input.summary?.positionLeverageUpdated?.doubleValue, positionLeverageUpdated > marketMaxLeverage {
                    return "ERRORS.TRADE_BOX_TITLE.INVALID_NEW_POSITION_LEVERAGE"
                }
            }
            if let positionMarginUpdated = input.summary?.positionMarginUpdated?.doubleValue, positionMarginUpdated < 0 {
                return "ERRORS.TRADE_BOX.INVALID_NEW_ACCOUNT_MARGIN_USAGE"
            }
            if let freeCollateral = input.summary?.crossFreeCollateral?.doubleValue, amount >= freeCollateral {
                return "ERRORS.TRANSFER_MODAL.TRANSFER_MORE_THAN_FREE"
            }
        default:
            break
        }

        return nil
    }

    private func clearPostValues() {
        for receipt in [viewModel?.amountReceipt, viewModel?.buttonReceipt] {
            for item in receipt?.receiptChangeItems ?? [] {
                item.value?.after = nil
            }
        }
    }

    private func updatePrePostValues(input: AdjustIsolatedMarginInput, market: PerpetualMarket) {
        var crossReceiptItems = [dydxReceiptChangeItemView]()
        var positionReceiptItems = [dydxReceiptChangeItemView]()

        if let errorStringKey = validate(input: input, market: market) {
            clearPostValues()
            viewModel?.inlineAlert = InlineAlertViewModel(InlineAlertViewModel.Config(
                title: nil,
                body: DataLocalizer.localize(path: errorStringKey),
                level: .error))
            ctaButtonPresenter.viewModel?.ctaButtonState = .disabled()
            return
        } else {
            switch input.type {
            case .add:
                ctaButtonPresenter.viewModel?.ctaButtonState = .enabled(DataLocalizer.shared?.localize(path: "APP.TRADE.ADD_MARGIN", params: nil) ?? "")
            case .remove:
                ctaButtonPresenter.viewModel?.ctaButtonState = .enabled(DataLocalizer.shared?.localize(path: "APP.TRADE.REMOVE_MARGIN", params: nil) ?? "")
                default:
                assertionFailure("no margin direction")
            }
            viewModel?.inlineAlert = nil
        }

        let crossFreeCollateral: AmountTextModel = .init(amount: input.summary?.crossFreeCollateral, unit: .dollar)
        let crossFreeCollateralUpdated: AmountTextModel = .init(amount: input.summary?.crossFreeCollateralUpdated, unit: .dollar)
        let crossFreeCollateralChange: AmountChangeModel = .init(
            before: crossFreeCollateral.amount != nil ? crossFreeCollateral : nil,
            after: crossFreeCollateralUpdated.amount != nil ? crossFreeCollateralUpdated : nil)
        crossReceiptItems.append(
            dydxReceiptChangeItemView(
                title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_FREE_COLLATERAL"),
                value: crossFreeCollateralChange))

        let crossMarginUsage: AmountTextModel = .init(amount: input.summary?.crossMarginUsage, unit: .percentage)
        let crossMarginUsageUpdated: AmountTextModel = .init(amount: input.summary?.crossMarginUsageUpdated, unit: .percentage)
        let crossMarginUsageChange: AmountChangeModel = .init(
            before: crossMarginUsage.amount != nil ? crossMarginUsage : nil,
            after: crossMarginUsageUpdated.amount != nil ? crossMarginUsageUpdated : nil,
            increasingIsPositiveDirection: false)
        crossReceiptItems.append(
            dydxReceiptChangeItemView(
                title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_MARGIN_USAGE"),
                value: crossMarginUsageChange))

        let positionMargin: AmountTextModel = .init(amount: input.summary?.positionMargin, unit: .dollar)
        let positionMarginUpdated: AmountTextModel = .init(amount: input.summary?.positionMarginUpdated, unit: .dollar)
        let positionMarginChange: AmountChangeModel = .init(
            before: positionMargin.amount != nil ? positionMargin : nil,
            after: positionMarginUpdated.amount != nil ? positionMarginUpdated : nil)
        positionReceiptItems.append(
            dydxReceiptChangeItemView(
                title: DataLocalizer.localize(path: "APP.TRADE.POSITION_MARGIN"),
                value: positionMarginChange))

        let positionLeverage: AmountTextModel = .init(amount: input.summary?.positionLeverage?.abs(), unit: .multiplier)
        let positionLeverageUpdated: AmountTextModel = .init(amount: input.summary?.positionLeverageUpdated?.abs(), unit: .multiplier)
        let positionLeverageChange: AmountChangeModel = .init(
            before: positionLeverage.amount != nil ? positionLeverage : nil,
            after: positionLeverageUpdated.amount != nil ? positionLeverageUpdated : nil,
            increasingIsPositiveDirection: false
        )
        positionReceiptItems.append(
            dydxReceiptChangeItemView(
                title: DataLocalizer.localize(path: "APP.TRADE.POSITION_LEVERAGE"),
                value: positionLeverageChange))

        if input.type == IsolatedMarginAdjustmentType.add {
            viewModel?.amountReceipt?.receiptChangeItems = crossReceiptItems
            viewModel?.buttonReceipt?.receiptChangeItems = positionReceiptItems
        } else {
            viewModel?.amountReceipt?.receiptChangeItems = positionReceiptItems
            viewModel?.buttonReceipt?.receiptChangeItems = crossReceiptItems
        }
    }

    private func updateLiquidationPrice(input: AdjustIsolatedMarginInput, side: Abacus.PositionSide, market: PerpetualMarket) {
        if let displayTickSizeDecimals = market.configs?.displayTickSizeDecimals?.intValue {
            let curLiquidationPrice = input.summary?.liquidationPrice
            let postLiquidationPrice = input.summary?.liquidationPriceUpdated
            let currentLeverage = input.summary?.positionLeverage?.doubleValue ?? 0
            let postLeverage = input.summary?.positionLeverageUpdated?.doubleValue ?? 0

            viewModel?.liquidationPrice = dydxAdjustMarginLiquidationPriceViewModel()

            let hasNoInput = input.summary?.positionLeverageUpdated == nil

            if hasNoInput {
                // no input, no change, update accordingly
                viewModel?.liquidationPrice?.direction = .none
                if currentLeverage <= 1 && side == Abacus.PositionSide.long_ {
                    viewModel?.liquidationPrice?.before = DataLocalizer.shared?.localize(path: "APP.GENERAL.NONE", params: nil)
                } else {
                    viewModel?.liquidationPrice?.before = dydxFormatter.shared.dollar(number: curLiquidationPrice, digits: displayTickSizeDecimals)
                }
                viewModel?.liquidationPrice?.after = nil
            } else if side == Abacus.PositionSide.short_ {
                // else there is input, handle short positions which always have a liquidation price
                viewModel?.liquidationPrice?.before = dydxFormatter.shared.dollar(number: curLiquidationPrice, digits: displayTickSizeDecimals)
                viewModel?.liquidationPrice?.after = dydxFormatter.shared.dollar(number: postLiquidationPrice, digits: displayTickSizeDecimals)
            } else {
                // else there is input, handle long positions which sometimes have a liquidation price
                switch (currentLeverage <= 1, postLeverage <= 1) {
                    case (true, true):
                    viewModel?.liquidationPrice?.before = DataLocalizer.shared?.localize(path: "APP.GENERAL.NONE", params: nil)
                    viewModel?.liquidationPrice?.after = nil
                    case (true, false):
                    viewModel?.liquidationPrice?.before = DataLocalizer.shared?.localize(path: "APP.GENERAL.NONE", params: nil)
                    viewModel?.liquidationPrice?.after = dydxFormatter.shared.dollar(number: postLiquidationPrice, digits: displayTickSizeDecimals)
                    case (false, true):
                    viewModel?.liquidationPrice?.before = dydxFormatter.shared.dollar(number: curLiquidationPrice, digits: displayTickSizeDecimals)
                    viewModel?.liquidationPrice?.after = DataLocalizer.shared?.localize(path: "APP.GENERAL.NONE", params: nil)
                    case (false, false):
                    viewModel?.liquidationPrice?.before = dydxFormatter.shared.dollar(number: curLiquidationPrice, digits: displayTickSizeDecimals)
                    viewModel?.liquidationPrice?.after = dydxFormatter.shared.dollar(number: postLiquidationPrice, digits: displayTickSizeDecimals)
                }
            }

            switch input.type {
            case .add:
                // liquidation price is moving further from oracle price with less leverage
                viewModel?.liquidationPrice?.direction = hasNoInput ? .none : .safer
            case .remove:
                // liquidation price is moving closer to oracle price with more leverage
                viewModel?.liquidationPrice?.direction = hasNoInput ? .none : .riskier
            default:
                viewModel?.liquidationPrice?.direction = .none
            }
        }
    }

    private func updateFields(input: AdjustIsolatedMarginInput) {
        viewModel?.amount?.value = dydxFormatter.shared.raw(number: parser.asNumber(input.amount), digits: 2)
    }
}
