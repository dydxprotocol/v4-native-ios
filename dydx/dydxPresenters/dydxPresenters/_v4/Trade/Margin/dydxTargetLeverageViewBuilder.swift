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

        viewModel.leverageOptions = [
            dydxTargetLeverageViewModel.LeverageTextAndValue(text: "1x", value: 1.0),
            dydxTargetLeverageViewModel.LeverageTextAndValue(text: "2x", value: 2.0),
            dydxTargetLeverageViewModel.LeverageTextAndValue(text: "5x", value: 5.0),
            dydxTargetLeverageViewModel.LeverageTextAndValue(text: "10x", value: 10.0),
            dydxTargetLeverageViewModel.LeverageTextAndValue(text: "Max", value: 20.0)
        ]

        self.viewModel = viewModel
        
        // TODO: get from Abacus
        self.viewModel?.inlineAlert = .previewValue

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        // TODO: Fix... tradeInput?.targetLeverage is nil for now

        AbacusStateManager.shared.state.tradeInput
            .sink { [weak self] tradeInput in
                let value = dydxFormatter.shared.localFormatted(number: tradeInput?.targetLeverage ?? 1, digits: 1)
                self?.viewModel?.leverageInput?.value = value
            }
            .store(in: &subscriptions)
    }
}
