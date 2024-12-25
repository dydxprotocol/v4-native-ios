//
//  dydxSimpleUPortfolioViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/12/2024.
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

protocol dydxSimpleUIPortfolioViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIPortfolioViewModel? { get }
}

class dydxSimpleUIPortfolioViewPresenter: HostedViewPresenter<dydxSimpleUIPortfolioViewModel>, dydxSimpleUIPortfolioViewPresenterProtocol {

    private let accountPresenter = SharedAccountPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        accountPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIPortfolioViewModel()

        accountPresenter.$viewModel.assign(to: &viewModel.$sharedAccountViewModel)

        super.init()

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        Publishers.CombineLatest3(
            AbacusStateManager.shared.state.selectedSubaccount,
            AbacusStateManager.shared.state.selectedSubaccountPNLs,
            AbacusStateManager.shared.state.onboarded
        )
        .sink { [weak self] subaccount, pnls, onboarded in
            if subaccount?.freeCollateral?.current?.doubleValue ?? 0 > 0 {
                self?.viewModel?.state = .hasBalance
                self?.viewModel?.buttonAction = nil
                if let subaccount = subaccount {
                    self?.updatePNLs(pnls: pnls, subaccount: subaccount)
                }
            } else if onboarded {
                self?.viewModel?.state = .walletConnected
                self?.viewModel?.buttonAction = {
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
                }
            } else {
                self?.viewModel?.state = .loggedOut
                self?.viewModel?.buttonAction = {
                    Router.shared?.navigate(to: RoutingRequest(path: "/onboard"), animated: true, completion: nil)
                }
            }
        }
        .store(in: &subscriptions)

        attachChild(worker: accountPresenter)
    }

    private func updatePNLs(pnls: [SubaccountHistoricalPNL], subaccount: Subaccount) {
        let dataPoints = pnls.compactMap { HistoricalPNLDataPoint(pnl: $0) }

        let firstTotalPnl = pnls.first?.totalPnl
        let targetTotalPnl = pnls.last?.totalPnl
        let beginning = pnls.first?.equity

        if let firstTotalPnl = firstTotalPnl, let targetTotalPnl = targetTotalPnl, let beginning = beginning, beginning != 0 {
            viewModel?.pnlAmount = dydxFormatter.shared.dollar(number: targetTotalPnl - firstTotalPnl, digits: 2)
            let percent = dydxFormatter.shared.percent(number: abs(targetTotalPnl - firstTotalPnl) / beginning, digits: 2)
            viewModel?.pnlPercent = SignedAmountViewModel(text: percent, sign: targetTotalPnl >= firstTotalPnl ? .plus : .minus, coloringOption: .textOnly)
        }
    }
}
