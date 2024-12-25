//
//  dydxPortfolioViewBuilder.swift
//  dydxPresenter
//
//  Created by John Huang on 12/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import dydxStateManager
import SwiftUI
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine

public class dydxPortfolioViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxPortfolioViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxPortfolioViewController(presenter: presenter, view: view,
                                           configuration: .tabbarItemView) as? T
    }
}

private class dydxPortfolioViewController: HostingViewController<PlatformView, dydxPortfolioViewModel> {
     override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        let supportedPathes = [
            "/portfolio",
            "/portfolio/fees",
            "/portfolio/overview",
            "/portfolio/transfers",
            "/portfolio/orders",
            "/portfolio/positions",
            "/portfolio/trades"
        ]
        if let path = request?.path, supportedPathes.contains(path) {
            if let presenter = presenter as? dydxPortfolioViewPresenterProtocol {
                presenter.updateDisplayType(displayType: request?.path?.lastPathComponent)
            }
            return true
        }
        return false
    }
}

private protocol dydxPortfolioViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioViewModel? { get }
    func updateDisplayType(displayType: String?)
}

private class dydxPortfolioViewPresenter: HostedViewPresenter<dydxPortfolioViewModel>, dydxPortfolioViewPresenterProtocol {

    private let accountPresenter: SharedAccountPresenter
    private let transfersPresenter: dydxHistoricalTransfersViewPresenter
    private let feesPresenter: dydxPortfolioFeesViewPresenter
    private let fillsPresenter: dydxPortfolioFillsViewPresenter
    private let fundingPresenter: dydxPortfolioFundingViewPresenter
    private let positionsPresenter: dydxPortfolioPositionsViewPresenter
    private let ordersPresenter: dydxPortfolioOrdersViewPresenter
    private let chartPresenter: dydxPortfolioChartViewPresenter
    private let headerPresenter: dydxPortfolioHeaderPresenter
    private let selectorPresenter: dydxPortfolioSelectorViewPresenter

    private var displayContent: dydxPortfolioViewModel.DisplayContent?

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        accountPresenter,
        chartPresenter,
        headerPresenter,
        selectorPresenter
    ]

    private lazy var selectionPresenters: [PortfolioSection: HostedViewPresenterProtocol] = [
        .positions: positionsPresenter,
        .orders: ordersPresenter,
        .trades: fillsPresenter,
        .funding: fundingPresenter,
        .fees: feesPresenter,
        .transfers: transfersPresenter
    ]

    override init() {
        let viewModel = dydxPortfolioViewModel()
        accountPresenter = SharedAccountPresenter()
        transfersPresenter = dydxHistoricalTransfersViewPresenter(viewModel: viewModel.transfers)
        feesPresenter = dydxPortfolioFeesViewPresenter(viewModel: viewModel.fees)
        fillsPresenter = dydxPortfolioFillsViewPresenter(viewModel: viewModel.fills)
        fundingPresenter = dydxPortfolioFundingViewPresenter(viewModel: viewModel.funding)
        positionsPresenter = dydxPortfolioPositionsViewPresenter(viewModel: viewModel.positions)
        ordersPresenter = dydxPortfolioOrdersViewPresenter(viewModel: viewModel.orders)
        chartPresenter = dydxPortfolioChartViewPresenter(viewModel: viewModel.chart)
        headerPresenter = dydxPortfolioHeaderPresenter(viewModel: viewModel.header)
        selectorPresenter = dydxPortfolioSelectorViewPresenter(viewModel: viewModel.selector)

        super.init()

        // Candle
        accountPresenter.$viewModel.assign(to: &viewModel.details.$sharedAccountViewModel)

        viewModel.details.expandAction = { [weak self] in
            let expanded = !(self?.viewModel?.expanded ?? false)
            self?.viewModel?.details.expanded = expanded
            self?.viewModel?.expanded = expanded
        }
        viewModel.sections.itemTitles = Section.allSections.map(\.text)
        viewModel.sections.onSelectionChanged = { [weak self] index in
            if index <  Section.allSections.count {
                let selectedSection = Section.allSections[index]
                viewModel.sectionSelection = selectedSection.key
                viewModel.sections.sectionIndex = index
                self?.resetPresentersForVisibilityChange()
            }
        }
        viewModel.sectionSelection = .positions
        viewModel.sections.sectionIndex = 0

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        resetPresentersForVisibilityChange()
    }

    override func stop() {
        super.stop()

        for (_, presenter) in selectionPresenters {
            presenter.stop()
        }
    }

    func updateDisplayType(displayType: String?) {
        if let displayType = displayType {
            displayContent = dydxPortfolioViewModel.DisplayContent(rawValue: displayType) ?? .overview
        } else {
            displayContent = .overview
        }
        if let displayContent = displayContent {
            viewModel?.displayContent = displayContent
            selectorPresenter.updateSelection(displayContent: displayContent)
        }
        resetPresentersForVisibilityChange()
    }

    private func resetPresentersForVisibilityChange() {
        switch displayContent {
        case .overview:
            if let selection = viewModel?.sectionSelection {
                resetDisplayContent(selection: selection)
            }
        case .positions:
            resetDisplayContent(selection: .positions)
        case .orders:
            resetDisplayContent(selection: .orders)
        case .trades:
            resetDisplayContent(selection: .trades)
        case .payments:
            resetDisplayContent(selection: .funding)
        case .fees:
            resetDisplayContent(selection: .fees)
        case .transfers:
            resetDisplayContent(selection: .transfers)
        case .none:
            break
        }
    }

    private func resetDisplayContent(selection: PortfolioSection) {
        for (key, presenter) in selectionPresenters {
            if key == selection {
                if  presenter.isStarted == false {
                    presenter.start()
                }
            } else {
                presenter.stop()
            }
        }
    }
}

// MARK: Section

private struct Section: Equatable {
    let text: String
    let key: PortfolioSection

    static var allSections: [Self] {
        [
            Self(text: DataLocalizer.localize(path: "APP.TRADE.POSITIONS"), key: .positions),
            Self(text: DataLocalizer.localize(path: "APP.GENERAL.ORDERS"), key: .orders),
            Self(text: DataLocalizer.localize(path: "APP.GENERAL.TRADES"), key: .trades)
            // TODO: add back Funding when ready, see https://github.com/dydxprotocol/native-ios-v4/pull/118/files
        ]
    }
}
