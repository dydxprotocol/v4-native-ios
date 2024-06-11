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
        viewModel.amount?.maxAction = {
            AbacusStateManager.shared.adjustIsolatedMargin(input: "1", type: .amountpercent)
        }

        ctaButtonPresenter.viewModel?.ctaAction = {
            AbacusStateManager.shared.commitAdjustIsolatedMargin { [weak self] (_, error, _) in
                if let error = error {
                    self?.viewModel?.submissionError = InlineAlertViewModel(.init(title: nil, body: error.message, level: .error))
                } else {
                    self?.viewModel?.submissionError = nil
                }
            }
        }

        viewModel.amount?.placeHolder = "0.00"

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()
        guard let marketId, let childSubaccountNumber else { return }

        AbacusStateManager.shared.adjustIsolatedMargin(input: childSubaccountNumber, type: .childsubaccountnumber)

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.market(of: marketId).compactMap { $0 },
                AbacusStateManager.shared.state.assetMap,
                AbacusStateManager.shared.state.adjustIsolatedMarginInput.compactMap { $0 }
            )
            .sink { [weak self] market, assetMap, input in
                self?.updateState(market: market, assetMap: assetMap)
                self?.updateFields(input: input)
                self?.updateCalculatedValues(input: input, market: market)
            }
            .store(in: &subscriptions)
    }

    private func updateState(market: PerpetualMarket, assetMap: [String: Asset]) {
        let asset = assetMap[market.assetId]
        viewModel?.sharedMarketViewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
    }

    private func updateCalculatedValues(input: AdjustIsolatedMarginInput, market: PerpetualMarket) {
        switch input.type {
        case IsolatedMarginAdjustmentType.add:
            viewModel?.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT_TO_ADD")
        case IsolatedMarginAdjustmentType.remove:
            viewModel?.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT_TO_REMOVE")
        default:
            viewModel?.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT")
        }

        var crossFreeCollateralBefore: AmountTextModel?
        var crossFreeCollateralAfter: AmountTextModel?
        var crossMarginUsageBefore: AmountTextModel?
        var crossMarginUsageAfter: AmountTextModel?
        var positionMarginBefore: AmountTextModel?
        var positionMarginAfter: AmountTextModel?
        var positionLeverageBefore: AmountTextModel?
        var positionLeverageAfter: AmountTextModel?

        if let value = input.summary?.crossFreeCollateral {
            crossFreeCollateralBefore = .init(amount: value, unit: .dollar)
        }
        if let value = input.summary?.crossFreeCollateralUpdated {
            crossFreeCollateralAfter = .init(amount: value, unit: .dollar)
        }
        if let value = input.summary?.crossMarginUsage {
            crossMarginUsageBefore = .init(amount: value, unit: .percentage)
        }
        if let value = input.summary?.crossMarginUsageUpdated {
            crossMarginUsageAfter = .init(amount: value, unit: .percentage)
        }
        if let value = input.summary?.positionMargin {
            positionMarginBefore = .init(amount: value, unit: .dollar)
        }
        if let value = input.summary?.positionMarginUpdated {
            positionMarginAfter = .init(amount: value, unit: .dollar)
        }
        if let value = input.summary?.positionLeverage {
            positionLeverageBefore = .init(amount: value, unit: .multiplier)
        }
        if let value = input.summary?.positionLeverageUpdated {
            positionLeverageAfter = .init(amount: value, unit: .multiplier)
        }
        viewModel?.subaccountReceipt?.freeCollateral = AmountChangeModel(
            before: crossFreeCollateralBefore,
            after: crossFreeCollateralAfter)
        viewModel?.subaccountReceipt?.marginUsage = AmountChangeModel(
            before: crossMarginUsageBefore,
            after: crossMarginUsageAfter)
        viewModel?.positionReceipt?.marginUsage = AmountChangeModel(
            before: positionMarginBefore,
            after: positionMarginAfter)
        viewModel?.positionReceipt?.leverage = AmountChangeModel(
            before: positionLeverageBefore,
            after: positionLeverageAfter)

        if let displayTickSizeDecimals = market.configs?.displayTickSizeDecimals?.intValue {
            let before = input.summary?.liquidationPrice
            // the non-zero check here is a band-aid for an abacus bug where there is a pre- and post- state even on empty input
            let after = parser.asNumber(input.amount)?.doubleValue ?? 0 > 0 ? input.summary?.liquidationPriceUpdated : nil
            viewModel?.liquidationPrice = dydxAdjustMarginLiquidationPriceViewModel()
            viewModel?.liquidationPrice?.before = dydxFormatter.shared.dollar(number: before, digits: displayTickSizeDecimals)
            viewModel?.liquidationPrice?.after = after != nil ? dydxFormatter.shared.dollar(number: after, digits: displayTickSizeDecimals) : nil
            if let before, let after {
                if before > after {
                    // lowering liquidation price is "safer" so increase is the "positive" direction
                    viewModel?.liquidationPrice?.direction = .increase
                } else if before < after {
                    viewModel?.liquidationPrice?.direction = .decrease
                } else {
                    viewModel?.liquidationPrice?.direction = .none
                }
            } else {
                viewModel?.liquidationPrice?.direction = .none
            }
        }

        if parser.asNumber(input.amount)?.doubleValue ?? 0 > 0 {
            self.ctaButtonPresenter.viewModel?.ctaButtonState = .enabled()
        } else {
            self.ctaButtonPresenter.viewModel?.ctaButtonState = .disabled()
        }
    }

    private func updateFields(input: AdjustIsolatedMarginInput) {
        viewModel?.amount?.value = dydxFormatter.shared.raw(number: parser.asNumber(input.amount), digits: 2)
    }
}
