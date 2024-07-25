//
//  dydxTargetLeverageViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 07/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter
import Combine

public class dydxTargetLeverageViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTargetLeverageViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTargetLeverageViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTargetLeverageViewController: HostingViewController<PlatformView, dydxTargetLeverageViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/target_leverage" {
            return true
        }
        return false
    }
}

private protocol dydxTargetLeverageViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTargetLeverageViewModel? { get }
}

private class dydxTargetLeverageViewPresenter: HostedViewPresenter<dydxTargetLeverageViewModel>, dydxTargetLeverageViewPresenterProtocol {
    private let ctaButtonPresenter = dydxTargetLeverageCtaButtonViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        ctaButtonPresenter
    ]

    override init() {
        let viewModel = dydxTargetLeverageViewModel()

        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButton)

        super.init()

        viewModel.description = DataLocalizer.localize(path: "APP.TRADE.ADJUST_TARGET_LEVERAGE_DESCRIPTION")

        self.viewModel = viewModel

        self.viewModel?.optionSelectedAction = {[weak self] value in
            self?.update(value: value.value)
        }
        self.ctaButtonPresenter.viewModel?.ctaAction = {
            AbacusStateManager.shared.trade(input: viewModel.sliderTextInput.valueAsString, type: .targetleverage)
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        self.viewModel?.sliderTextInput.numberFormatter.fractionDigits = 2
        self.viewModel?.sliderTextInput.$value
            .removeDuplicates()
            .sink(receiveValue: { [weak self] value in
                self?.update(value: value)
            })
            .store(in: &subscriptions)

        attachChildren(workers: childPresenters)
    }

    private func update(value: Double?) {
        let value = value ?? 0
        viewModel?.sliderTextInput.value = value
        viewModel?.selectedOptionIndex = viewModel?.leverageOptions.firstIndex(where: { option in
            option.value == value
        })
        if value > 0 {
            viewModel?.ctaButton?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.TRADE.CONFIRM_LEVERAGE"))
        } else {
            viewModel?.ctaButton?.ctaButtonState = .disabled(DataLocalizer.localize(path: "APP.TRADE.CONFIRM_LEVERAGE"))
        }
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(AbacusStateManager.shared.state.configsAndAssetMap,
                       AbacusStateManager.shared.state.tradeInput)
            .compactMap { $0 }
            .sink { [weak self] configsAndAssetMap, tradeInput in
                guard let viewModel = self?.viewModel, let marketId = tradeInput?.marketId, let market = configsAndAssetMap[marketId] else { return }
                if let effectiveInitialMarginFraction = market.configs?.effectiveInitialMarginFraction?.doubleValue, effectiveInitialMarginFraction > 0 {
                    let maxLeverage = 1.0 / effectiveInitialMarginFraction
                    viewModel.sliderTextInput.maxValue = maxLeverage
                    viewModel.leverageOptions = [1, 2, 3, 5, 10]
                        .filter { $0 < maxLeverage }
                        .map { dydxTargetLeverageViewModel.LeverageTextAndValue(text: dydxFormatter.shared.multiplier(number: Double($0)) ?? "", value: $0) }
                    viewModel.leverageOptions.append(dydxTargetLeverageViewModel.LeverageTextAndValue(text: DataLocalizer.localize(path: "APP.GENERAL.MAX"), value: maxLeverage))
                }

                self?.update(value: tradeInput?.targetLeverage ?? 1)
            }
            .store(in: &subscriptions)
    }
}
