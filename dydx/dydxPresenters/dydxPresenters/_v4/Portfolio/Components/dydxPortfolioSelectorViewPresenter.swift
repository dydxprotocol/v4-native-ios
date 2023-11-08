//
//  dydxPortfolioSelectorViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/23/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter

protocol dydxPortfolioSelectorViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioSelectorViewModel? { get }
    func updateSelection(displayContent: dydxPortfolioViewModel.DisplayContent)
}

class dydxPortfolioSelectorViewPresenter: HostedViewPresenter<dydxPortfolioSelectorViewModel>, dydxPortfolioSelectorViewPresenterProtocol {

    // TODO: add payments when ready
    private let displayContents: [dydxPortfolioViewModel.DisplayContent] = [
        .overview,
        .positions,
        .orders,
        .fees,
        .trades,
        .transfers
    ].filterNils()

    private func titleText(forDisplayContent displayContent: dydxPortfolioViewModel.DisplayContent) -> String {
        let path: String
        switch displayContent {
        case .overview: path = "APP.GENERAL.OVERVIEW"
        case .positions: path = "APP.TRADE.POSITIONS"
        case .orders: path = "APP.GENERAL.ORDERS"
        case .trades: path = "APP.TRADE.TRADES"
        case .fees: path = "APP.GENERAL.FEES"
        case .transfers: path = "APP.GENERAL.TRANSFERS"
        case .payments: path = "APP.TRADE.PAYMENTS"
        }
        return DataLocalizer.localize(path: path)
    }

    private func subtitleText(forDisplayContent displayContent: dydxPortfolioViewModel.DisplayContent) -> String {
        let path: String
        switch displayContent {
        case .overview: path = "APP.PORTFOLIO.OVERVIEW_DESCRIPTION"
        case .positions: path = "APP.PORTFOLIO.POSITIONS_DESCRIPTION"
        case .orders: path = "APP.PORTFOLIO.ORDERS_DESCRIPTION"
        case .trades: path = "APP.PORTFOLIO.TRADES_DESCRIPTION"
        case .fees: path = "APP.PORTFOLIO.FEE_STRUCTURE"
        case .transfers: path = "APP.PORTFOLIO.TRANSFERS_DESCRIPTION"
        case .payments: path = "APP.PORTFOLIO.PAYMENTS_DESCRIPTION"
        }
        return DataLocalizer.localize(path: path)
    }

    init(viewModel: dydxPortfolioSelectorViewModel?) {
        super.init()

        self.viewModel = viewModel

        self.viewModel?.items = displayContents.map({ displayContent in
            return dydxPortfolioSelectorViewModel.Item(
                title: titleText(forDisplayContent: displayContent),
                subtitle: subtitleText(forDisplayContent: displayContent),
                action: { [weak self] in
                    self?.show(displayType: displayContent.rawValue)
                })
        })
    }

    func updateSelection(displayContent: dydxViews.dydxPortfolioViewModel.DisplayContent) {
        viewModel?.selectedIndex = displayContents.firstIndex(of: displayContent) ?? 0
    }

    private func show(displayType: String) {
        Router.shared?.navigate(to: RoutingRequest(path: "/portfolio".stringByAppendingPathComponent(path: displayType)), animated: false, completion: nil)
    }
}
