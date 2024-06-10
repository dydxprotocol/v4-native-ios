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
        if request?.path == "/trade/adjust_margin", let marketId = parser.asString(request?.params?["marketId"]) {
            let presenter = presenter as? dydxAdjustMarginInputViewPresenterProtocol
            presenter?.marketId = marketId
            return true
        }
        return false
    }
}

private protocol dydxAdjustMarginInputViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAdjustMarginInputViewModel? { get }
    var marketId: String? { get set }
}

private class dydxAdjustMarginInputViewPresenter: HostedViewPresenter<dydxAdjustMarginInputViewModel>, dydxAdjustMarginInputViewPresenterProtocol {
    private let ctaButtonPresenter = dydxAdjustMarginCtaButtonViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        ctaButtonPresenter
    ]

    var marketId: String?

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

        viewModel.marginPercentage?.percentageOptions = percentageOptions
        viewModel.marginPercentage?.percentageOptionSelectedAction = { option in
            AbacusStateManager.shared.adjustIsolatedMargin(input: option.percentage.stringValue, type: .amountpercent)
        }
        viewModel.amount?.onEdited = { amount in
            AbacusStateManager.shared.adjustIsolatedMargin(input: amount, type: .amount)
        }
        viewModel.amount?.maxAction = {
            AbacusStateManager.shared.adjustIsolatedMargin(input: "100", type: .amountpercent)
        }

        viewModel.amount?.label = DataLocalizer.localize(path: "APP.GENERAL.AMOUNT")
        viewModel.amount?.placeHolder = "0.00"

        viewModel.liquidationPrice?.before = dydxFormatter.shared.dollar(number: 1234.56, digits: 2)

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        if let marketId = marketId {
            Publishers
                .CombineLatest(
                    AbacusStateManager.shared.state.market(of: marketId).compactMap { $0 },
                    AbacusStateManager.shared.state.assetMap)
                .sink { [weak self] market, assetMap in
                    self?.updateState(market: market, assetMap: assetMap)
                }
                .store(in: &subscriptions)

            AbacusStateManager.shared.state.adjustIsolatedMarginInput
                .compactMap { $0 }
                .sink(receiveValue: { [weak self] input in
                    self?.updateFields(input: input)
                })
                .store(in: &subscriptions)
        }
    }

    private func updateState(market: PerpetualMarket, assetMap: [String: Asset]) {
        let asset = assetMap[market.assetId]
        viewModel?.sharedMarketViewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
    }

    private func updateFields(input: AdjustIsolatedMarginInput) {
        viewModel?.amount?.value = dydxFormatter.shared.dollar(number: parser.asNumber(input.amount))
        let selectedIndex = percentageOptions.firstIndex(where: { $0.percentage.stringValue == input.amountPercent })
        viewModel?.marginPercentage?.selectedPercentageOptionIndex = selectedIndex
    }
}
