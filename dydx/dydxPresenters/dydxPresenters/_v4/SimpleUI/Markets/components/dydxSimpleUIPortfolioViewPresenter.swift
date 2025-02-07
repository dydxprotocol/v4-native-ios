//
//  dydxSimpleUPortfolioViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
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

        updateChartResolutions()

        viewModel.learnMoreAction = {
            if let urlString = AbacusStateManager.shared.environment?.links?.simpleTradeLearnMore,
               let url = URL(string: urlString) {
                if URLHandler.shared?.canOpenURL(url) ?? false {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.setHistoricalPNLPeriod(period: HistoricalPnlPeriod.period7d)

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
                        self?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
                    }
                } else {
                    self?.viewModel?.state = .loggedOut
                    self?.viewModel?.buttonAction = {
                        self?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
                    }
                }
            }
        }
        .store(in: &subscriptions)

        attachChild(worker: accountPresenter)
    }

    private var lastPnls: [SubaccountHistoricalPNL]?
    private var lastSubaccountBalance: Double?
    private var lastChartEntries: [dydxLineChartViewModel.Entry]?

    private func updatePNLs(pnls: [SubaccountHistoricalPNL], subaccount: Subaccount) {
        if lastPnls == pnls && lastSubaccountBalance == subaccount.equity?.current?.doubleValue {
            return
        }

        let firstEquity = pnls.first?.equity
        let targetEquity = subaccount.equity?.current?.doubleValue ?? pnls.last?.equity
        let beginning = pnls.first?.equity

        if let firstEquity = firstEquity, let targetEquity = targetEquity, let beginning = beginning, beginning != 0 {
            let amount =  dydxFormatter.shared.dollar(number: targetEquity - firstEquity, digits: 2)
            viewModel?.pnlAmount = SignedAmountViewModel(text: amount, sign: targetEquity >= firstEquity ? .plus : .minus, coloringOption: .textOnly)

            let percent = dydxFormatter.shared.percent(number: abs(targetEquity - firstEquity) / beginning, digits: 2)
            if let percent {
                viewModel?.pnlPercent = SignedAmountViewModel(text: "(" + percent + ")", sign: targetEquity >= firstEquity ? .plus : .minus, coloringOption: .textOnly)
            } else {
                viewModel?.pnlAmount = nil
            }
        }

        var chartEntries = lastChartEntries
        if lastPnls != pnls {
            let entries = pnls.compactMap {
                let date = $0.createdAtMilliseconds / 1000
                let value = $0.equity
                return dydxLineChartViewModel.Entry(date: date, value: value)
            }
            let maxEntryCount = 200 // for fast rendering
            if entries.count > maxEntryCount {
                var interpolatedEntries: [dydxLineChartViewModel.Entry] = []
                let step = entries.count / maxEntryCount
                for i in 0..<maxEntryCount {
                    if i * step < entries.count {
                        interpolatedEntries.append(entries[i * step])
                    }
                }
                chartEntries = interpolatedEntries
            } else {
                chartEntries = entries
            }
            lastChartEntries = chartEntries
        }

        if var chartEntries {
            if let currentValue = subaccount.equity?.current?.doubleValue {
                chartEntries.append(dydxLineChartViewModel.Entry(date: Double(Date().millisecondsSince1970) / 1000, value: currentValue))
            }
            let maxValue = chartEntries.max { $0.value < $1.value }?.value ?? 0
            let minValue = chartEntries.min { $0.value < $1.value }?.value ?? 0

            viewModel?.chart.entries = chartEntries
            viewModel?.chart.showYLabels = false
            viewModel?.chart.valueLowerBoundOffset = (maxValue - minValue) * 0.8
        }

        lastPnls = pnls
        lastSubaccountBalance = subaccount.equity?.current?.doubleValue
    }

    private func updateChartResolutions() {
        viewModel?.periodOption.items =  PortfolioChartResolution.allResolutions.map {
            dydxSimpleUIPortfolioPeriodViewModel.OptionItem(text: $0.text, value: $0.key.rawValue)
        }
        viewModel?.periodOption.selectedIndex = 1
        viewModel?.periodOption.selectAction = { index in
            AbacusStateManager.shared.setHistoricalPNLPeriod(period: PortfolioChartResolution.allResolutions[index].key)
        }
    }
}
