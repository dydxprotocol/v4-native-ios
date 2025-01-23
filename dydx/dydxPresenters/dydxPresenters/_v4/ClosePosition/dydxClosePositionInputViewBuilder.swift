//
//  dydxClosePositionInputViewBuilder.swift
//  dydxPresenter
//
//  Created by John Huang on 2/14/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import PlatformRouting
import PanModal

public class dydxClosePositionInputViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxClosePositionInputViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        // note this fixed height is to combat issues with the hide/show details button which changes the content height.
        let configuration = HostingViewControllerConfiguration(fixedHeight: 600)
        return dydxClosePositionInputViewController(presenter: presenter, view: view, configuration: configuration) as? T
    }
}

private class dydxClosePositionInputViewController: HostingViewController<PlatformView, dydxClosePositionInputViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/close", let marketId = parser.asString(request?.params?["marketId"]) {
            AbacusStateManager.shared.setMarket(market: marketId)
            AbacusStateManager.shared.startClosePosition(marketId: marketId)
            return true
        }
        return false
    }
}

private protocol dydxClosePositionInputViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxClosePositionInputViewModel? { get }
}

private class dydxClosePositionInputViewPresenter: HostedViewPresenter<dydxClosePositionInputViewModel>, dydxClosePositionInputViewPresenterProtocol {

    private let orderbookPresenter = dydxOrderbookPresenter()
    private let editPresenter = dydxClosePositionInputEditViewPresenter()
    private let ctaButtonPresenter = dydxClosePositionInputCtaButtonViewPresenter()
    private let validationPresenter = dydxValidationViewPresenter(receiptType: .trade(.close))
    private let headerPresenter = dydxClosePositionHeaderViewPresenter()
    private let orderbookGroupPresenter = dydxOrderbookGroupViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        orderbookPresenter,
        editPresenter,
        ctaButtonPresenter,
        validationPresenter,
        headerPresenter,
        orderbookGroupPresenter
    ]

    override init() {
        let viewModel = dydxClosePositionInputViewModel()

        orderbookPresenter.$viewModel.assign(to: &viewModel.$orderbookViewModel)
        editPresenter.$viewModel.assign(to: &viewModel.$editViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButtonViewModel)
        validationPresenter.$viewModel.assign(to: &viewModel.$validationViewModel)
        headerPresenter.$viewModel.assign(to: &viewModel.$headerViewModel)
        orderbookGroupPresenter.$viewModel.assign(to: &viewModel.$group)

        super.init()

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.closePositionInput
            .map(\.?.marketId)
            .assign(to: &orderbookPresenter.$marketId)

        AbacusStateManager.shared.state.closePositionInput
            .map(\.?.marketId)
            .assign(to: &orderbookGroupPresenter.$marketId)

        AbacusStateManager.shared.state.closePositionInput
            .map { input -> OrderbookDisplay in
                guard let side = input?.side else {
                    return .all
                }
                switch side {
                case .buy:
                    return .asks
                case .sell:
                    return .bids
                default:
                    break
                }
                return .all
            }
            .assign(to: &orderbookPresenter.$display)
    }
}
