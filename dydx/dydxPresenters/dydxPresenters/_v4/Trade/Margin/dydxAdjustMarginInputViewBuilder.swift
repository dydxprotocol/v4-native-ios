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

        viewModel.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT")
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
        viewModel?.subaccountReceipt?.freeCollateral = nil
        viewModel?.subaccountReceipt?.marginUsage = nil
        viewModel?.positionReceipt?.marginUsage = nil
        viewModel?.positionReceipt?.leverage = nil
        viewModel?.liquidationPrice = nil

        if let before = input.summary?.crossFreeCollateral,
           let after = input.summary?.crossFreeCollateralUpdated {
            viewModel?.subaccountReceipt?.freeCollateral = AmountChangeModel(
                before: AmountTextModel(amount: NSNumber(value: before.doubleValue), tickSize: 0.01, unit: .dollar),
                after: AmountTextModel(amount: NSNumber(value: after.doubleValue), tickSize: 0.01, unit: .dollar))
        }
        if let before = input.summary?.crossMarginUsage,
           let after = input.summary?.crossMarginUsageUpdated {
            viewModel?.subaccountReceipt?.marginUsage = AmountChangeModel(
                before: AmountTextModel(amount: NSNumber(value: before.doubleValue), tickSize: 0.01, unit: .percentage),
                after: AmountTextModel(amount: NSNumber(value: after.doubleValue), tickSize: 0.01, unit: .percentage))
        }

        if let before = input.summary?.positionMargin,
           let after = input.summary?.positionMarginUpdated {
            viewModel?.positionReceipt?.marginUsage = AmountChangeModel(
                before: AmountTextModel(amount: NSNumber(value: before.doubleValue), tickSize: 0.01, unit: .dollar),
                after: AmountTextModel(amount: NSNumber(value: after.doubleValue), tickSize: 0.01, unit: .dollar))
        }

        if let before = input.summary?.positionLeverage,
           let after = input.summary?.positionLeverageUpdated {
            viewModel?.positionReceipt?.leverage = AmountChangeModel(
                before: AmountTextModel(amount: NSNumber(value: before.doubleValue), tickSize: 0.01, unit: .multiplier),
                after: AmountTextModel(amount: NSNumber(value: after.doubleValue), tickSize: 0.01, unit: .multiplier))
        }

        if let before = input.summary?.liquidationPrice,
           let after = input.summary?.liquidationPriceUpdated,
           let displayTickSizeDecimals = market.configs?.displayTickSizeDecimals?.intValue {
            viewModel?.liquidationPrice = dydxAdjustMarginLiquidationPriceViewModel()
            viewModel?.liquidationPrice?.before = dydxFormatter.shared.dollar(number: before, digits: displayTickSizeDecimals)
            viewModel?.liquidationPrice?.after = dydxFormatter.shared.dollar(number: after, digits: displayTickSizeDecimals)
            if before > after {
                // lowering liquidation price is "safer" so increase is the "positive" direction
                viewModel?.liquidationPrice?.direction = .increase
            } else if before < after {
                viewModel?.liquidationPrice?.direction = .decrease
            } else {
                viewModel?.liquidationPrice?.direction = .none
            }
        }
    }

    private func updateFields(input: AdjustIsolatedMarginInput) {
        viewModel?.amount?.value = dydxFormatter.shared.raw(number: parser.asNumber(input.amount), digits: 2)
        let selectedIndex = percentageOptions.firstIndex(where: { $0.percentage.stringValue == input.amountPercent })
        viewModel?.marginPercentage?.selectedPercentageOptionIndex = selectedIndex
    }
}
