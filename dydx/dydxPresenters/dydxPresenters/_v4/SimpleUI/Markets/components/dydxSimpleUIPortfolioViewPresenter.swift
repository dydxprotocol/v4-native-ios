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

    private var loadingStartTime: Date?

    private static let loadingDelay: TimeInterval = 2.0

    override init() {
        let viewModel = dydxSimpleUIPortfolioViewModel()

        accountPresenter.$viewModel.assign(to: &viewModel.$sharedAccountViewModel)

        super.init()

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.setHistoricalPNLPeriod(period: HistoricalPnlPeriod.period30d)

        loadingStartTime = Date()
        Publishers.CombineLatest4(
            AbacusStateManager.shared.state.selectedSubaccount,
            AbacusStateManager.shared.state.selectedSubaccountPNLs,
            AbacusStateManager.shared.state.onboarded,
            Timer.publish(every: Self.loadingDelay, on: .main, in: .default).autoconnect()
        )
        .sink { [weak self] subaccount, pnls, onboarded, _ in
            if subaccount?.freeCollateral?.current?.doubleValue ?? 0 > 0 {
                self?.viewModel?.state = .hasBalance
                self?.viewModel?.buttonAction = nil
                if let subaccount = subaccount {
                    self?.updatePNLs(pnls: pnls, subaccount: subaccount)
                }
            } else if let loadingStartTime = self?.loadingStartTime, Date().timeIntervalSince(loadingStartTime) > Self.loadingDelay {
                if onboarded {
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
        }
        .store(in: &subscriptions)

        attachChild(worker: accountPresenter)
    }

    private func updatePNLs(pnls: [SubaccountHistoricalPNL], subaccount: Subaccount) {
        let firstTotalPnl = pnls.first?.totalPnl
        let targetTotalPnl = subaccount.pnlTotal?.doubleValue ?? pnls.last?.totalPnl
        let beginning = pnls.first?.equity

        if let firstTotalPnl = firstTotalPnl, let targetTotalPnl = targetTotalPnl, let beginning = beginning, beginning != 0 {
            viewModel?.pnlAmount = dydxFormatter.shared.dollar(number: targetTotalPnl - firstTotalPnl, digits: 2)
            let percent = dydxFormatter.shared.percent(number: abs(targetTotalPnl - firstTotalPnl) / beginning, digits: 2)
            viewModel?.pnlPercent = SignedAmountViewModel(text: percent, sign: targetTotalPnl >= firstTotalPnl ? .plus : .minus, coloringOption: .textOnly)
        }

        var chartEntries = pnls.compactMap {
            let date = $0.createdAtMilliseconds / 1000
            let value = $0.equity
            return dydxLineChartViewModel.Entry(date: date, value: value)
        }
        if let currentValue = subaccount.equity?.current?.doubleValue {
            chartEntries.append(dydxLineChartViewModel.Entry(date: Double(Date().millisecondsSince1970) / 1000, value: currentValue))
        }
        let maxValue = chartEntries.max { $0.value < $1.value }?.value ?? 0
        let minValue = chartEntries.min { $0.value < $1.value }?.value ?? 0

        // only update when there is significant change
        if chartEntries.count != viewModel?.chart.entries.count ||
            abs((chartEntries.last?.value ?? 0) - (viewModel?.chart.entries.last?.value ?? 0)) > 1.0 {
            viewModel?.chart.entries = chartEntries
        }

        viewModel?.chart.showYLabels = false
        viewModel?.chart.valueLowerBoundOffset = (maxValue - minValue) * 0.8
    }
}
