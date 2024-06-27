//
//  dydxMarginModeViewBuilder.swift
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
import dydxStateManager
import Abacus

public class dydxMarginModeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarginModeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxMarginModeViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxMarginModeViewController: HostingViewController<PlatformView, dydxMarginModeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/margin_mode" {
            return true
        }
        return false
    }
}

private protocol dydxMarginModeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarginModeViewModel? { get }
}

private class dydxMarginModeViewPresenter: HostedViewPresenter<dydxMarginModeViewModel>, dydxMarginModeViewPresenterProtocol {
    private let crossItemViewModel = dydxMarginModeItemViewModel(title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_MARGIN"),
                                                                 detail: DataLocalizer.localize(path: "APP.GENERAL.CROSS_MARGIN_DESCRIPTION"),
                                                                 isSelected: true,
                                                                 selectedAction: {
                                                                     AbacusStateManager.shared.trade(input: MarginMode.cross.rawValue, type: .marginmode)
                                                                     Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
                                                                 })

    private let isolatedItemViewModel = dydxMarginModeItemViewModel(title: DataLocalizer.localize(path: "APP.GENERAL.ISOLATED_MARGIN"),
                                                                    detail: DataLocalizer.localize(path: "APP.GENERAL.ISOLATED_MARGIN_DESCRIPTION"),
                                                                    isSelected: false,
                                                                    selectedAction: {
                                                                        AbacusStateManager.shared.trade(input: MarginMode.isolated.rawValue, type: .marginmode)
                                                                        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
                                                                    })

    override init() {
        super.init()

        viewModel = dydxMarginModeViewModel()
        viewModel?.items = [crossItemViewModel, isolatedItemViewModel]
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput
            .compactMap { $0 }
            .sink {[weak self] input in
                self?.update(tradeInput: input)
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: Abacus.TradeInput) {
        viewModel?.market = tradeInput.marketId
        let isSelectionDisabled = tradeInput.options?.marginModeOptions == nil
        viewModel?.isDisabled = isSelectionDisabled
        switch tradeInput.marginMode {
        case .cross:
            crossItemViewModel.isSelected = true
            isolatedItemViewModel.isSelected = false
            isolatedItemViewModel.isDisabled = tradeInput.options?.marginModeOptions == nil
        case .isolated:
            crossItemViewModel.isSelected = false
            crossItemViewModel.isDisabled = tradeInput.options?.marginModeOptions == nil
            isolatedItemViewModel.isSelected = true
        default:
            assertionFailure("should have margin mode")
            return
        }
    }
}
