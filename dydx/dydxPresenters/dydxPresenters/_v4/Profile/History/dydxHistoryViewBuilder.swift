//
//  dydxHistoryViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/3/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxHistoryViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxHistoryViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxHistoryViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxHistoryViewController: HostingViewController<PlatformView, dydxHistoryViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/portfolio/history" {
            let inTabBar = parser.asBoolean(request?.params?["inTabBar"])?.boolValue ?? true
            if inTabBar {
                configuration = .tabbarItemView
            } else {
                configuration = .default
            }
            return true
        }
        return false
    }
}

private protocol dydxHistoryViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxHistoryViewModel? { get }
}

private class dydxHistoryViewPresenter: HostedViewPresenter<dydxHistoryViewModel>, dydxHistoryViewPresenterProtocol {
    private let transfersPresenter: dydxHistoricalTransfersViewPresenter
    private let fillsPresenter: dydxPortfolioFillsViewPresenter
    private let fundingPresenter: dydxPortfolioFundingViewPresenter

    private lazy var sectionOrder: [dydxHistoryViewModel.DisplayContent] = [
       .trades, .transfers, .payments
    ]

    private lazy var selectionPresenters: [dydxHistoryViewModel.DisplayContent: HostedViewPresenterProtocol] = [
        .trades: fillsPresenter,
        .payments: fundingPresenter,
        .transfers: transfersPresenter
    ]

    private var displayContent: dydxHistoryViewModel.DisplayContent? {
        didSet {
            if let displayContent = displayContent {
                resetDisplayContent(selection: displayContent)
                viewModel?.displayContent = displayContent
            }
        }
    }

    override init() {
        let viewModel = dydxHistoryViewModel()
        viewModel.headerViewModel?.title = DataLocalizer.localize(path: "APP.GENERAL.HISTORY")
        viewModel.headerViewModel?.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        fillsPresenter = dydxPortfolioFillsViewPresenter(viewModel: viewModel.fills)
        transfersPresenter = dydxHistoricalTransfersViewPresenter(viewModel: viewModel.transfers)
        fundingPresenter = dydxPortfolioFundingViewPresenter(viewModel: viewModel.funding)

        super.init()

        self.viewModel = viewModel

        updateSelectionBar()
    }

    override func start() {
        super.start()

        if let displayContent = displayContent {
            resetDisplayContent(selection: displayContent)
        } else {
            displayContent = .trades
        }
    }

    override func stop() {
        super.stop()

        for (_, presenter) in selectionPresenters {
            presenter.stop()
        }
    }

    private func resetDisplayContent(selection: dydxHistoryViewModel.DisplayContent) {
        for (key, presenter) in selectionPresenters {
            if key == selection {
                if presenter.isStarted == false {
                    presenter.start()
                }
            } else {
                presenter.stop()
            }
        }
    }

    private func updateSelectionBar() {
        let selectionBar = SelectionBarModel()
        selectionBar.items = [
            SelectionBarModel.Item(text: DataLocalizer.localize(path: "APP.GENERAL.TRADES"), isSelected: true),
            SelectionBarModel.Item(text: DataLocalizer.localize(path: "APP.GENERAL.TRANSFERS"), isSelected: false)
         //   SelectionBarModel.Item(text: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_PAYMENTS_SHORT"), isSelected: false)
        ]
        selectionBar.onSelectionChanged = { [weak self] selectedIndex in
            guard let self = self else {
                return
            }
            for index in 0..<(selectionBar.items?.count ?? 0) {
                selectionBar.items?[index].isSelected = selectedIndex == index
            }
            self.viewModel?.objectWillChange.send()

            self.displayContent = self.sectionOrder[selectedIndex]
        }

        viewModel?.selectionBar = selectionBar
    }
}
