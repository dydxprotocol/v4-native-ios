//
//  dydxPortfolioChartViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/9/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Combine
import dydxFormatter

protocol dydxPortfolioChartViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioChartViewModel? { get }
}

class dydxPortfolioChartViewPresenter: HostedViewPresenter<dydxPortfolioChartViewModel>, dydxPortfolioChartViewPresenterProtocol {
    @Published private var selectedChartEntry: dydxLineChartViewModel.Entry?

    init(viewModel: dydxPortfolioChartViewModel?) {
        super.init()

        self.viewModel = viewModel

        let defaultResolutionIndex = 1
        viewModel?.resolutionTitles = PortfolioChartResolution.allResolutions.map(\.text)
        viewModel?.resolutionIndex = defaultResolutionIndex
        viewModel?.pnlLabel = DataLocalizer.localize(path: "APP.GENERAL.PROFIT_AND_LOSS_WITH_DURATION", params: ["PERIOD": PortfolioChartResolution.allResolutions[defaultResolutionIndex].text])
        AbacusStateManager.shared.setHistoricalPNLPeriod(period: PortfolioChartResolution.allResolutions[defaultResolutionIndex].key)

        viewModel?.onResolutionChanged = { index in
            if index < PortfolioChartResolution.allResolutions.count {
                viewModel?.resolutionIndex = index
                viewModel?.pnlLabel = DataLocalizer.localize(path: "APP.GENERAL.PROFIT_AND_LOSS_WITH_DURATION", params: ["PERIOD": PortfolioChartResolution.allResolutions[index].text])
                AbacusStateManager.shared.setHistoricalPNLPeriod(period: PortfolioChartResolution.allResolutions[index].key)
             }
        }
    }

    override func start() {
        super.start()

        Publishers
           .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountPNLs,
                           AbacusStateManager.shared.state.selectedSubaccount,
                           $selectedChartEntry)
           .sink { [weak self] pnls, subaccount, selectedChartEntry in
               if let subaccount = subaccount {
                   self?.viewModel?.state = .onboardCompleted
                   self?.updatePNLs(pnls: pnls, subaccount: subaccount, selectedChartEntry: selectedChartEntry)
               } else {
                   self?.viewModel?.state = .onboard
                   self?.viewModel?.equity = nil
                   self?.viewModel?.pnl = nil
               }
           }
           .store(in: &subscriptions)
    }

    private func updatePNLs(pnls: [SubaccountHistoricalPNL], subaccount: Subaccount, selectedChartEntry: dydxLineChartViewModel.Entry?) {

        var entries = pnls.compactMap {
            dydxLineChartViewModel.Entry(date: $0.createdAtMilliseconds, value: $0.equity)
        }
        if let equity = subaccount.equity?.current?.doubleValue {
            // Add the current PNL
            let date = Date().timeIntervalSince1970 * 1000
            let lastPoint = dydxLineChartViewModel.Entry(date: date, value: equity)
            entries += [lastPoint]
        }
        let maxValue = entries.max { $0.value < $1.value }?.value ?? 0
        let minValue = entries.min { $0.value < $1.value }?.value ?? 0

        viewModel?.chart.entries = entries
        viewModel?.chart.showYLabels = false
        viewModel?.chart.valueLowerBoundOffset = (maxValue - minValue) * 0.8
        viewModel?.chart.dataPointSelected = { [weak self] entry in
            self?.selectedChartEntry = entry
        }

        let firstEquity = pnls.first?.equity
        let targetEquity: Double?
        if let selectedChartEntry {
            targetEquity = selectedChartEntry.value
            viewModel?.equity = dydxFormatter.shared.dollar(number: selectedChartEntry.value, size: nil)
            viewModel?.equityLabel = Date(milliseconds: selectedChartEntry.date).localDatetimeString
        } else {
            targetEquity = subaccount.equity?.current?.doubleValue
            viewModel?.equity = dydxFormatter.shared.dollar(number: subaccount.equity?.current?.doubleValue ?? 0, size: nil)
            viewModel?.equityLabel = DataLocalizer.localize(path: "APP.PORTFOLIO.PORTFOLIO_VALUE")
        }
        if let firstEquity = firstEquity, let targetEquity = targetEquity {
            displayChange(from: firstEquity, to: targetEquity, beginning: pnls.first?.equity)
        }
    }

    private func displayChange(from: Double, to: Double, beginning: Double?) {
        let amount = changeText(from: from, to: to, beginning: beginning) ?? ""
        viewModel?.pnl = SignedAmountViewModel(text: amount, sign: to >= from ? .plus : .minus, coloringOption: .textOnly)
    }

    private func changeText(from: Double, to: Double, beginning: Double?) -> String? {
        if let change = dydxFormatter.shared.dollar(number: NSNumber(value: to - from), size: nil) {
            if let beginning = beginning, beginning != Double.zero {
                if let percent = changePercentText(from: from, to: to, beginning: beginning) {
                    return "\(change) (\(percent))"
                } else {
                    return change
                }
            } else {
                return change
            }
        } else {
            return nil
        }
    }

    private func changePercentText(from: Double, to: Double, beginning: Double?, omitSign: Bool = true) -> String? {
        if let beginning = beginning, beginning != Double.zero {
            var percent = NSNumber(value: (to - from) / beginning)
            if omitSign {
                percent = percent.abs()
            }
            return dydxFormatter.shared.percent(number: percent, digits: 2)
        } else {
            return nil
        }
    }
}

// MARK: Resolution

struct PortfolioChartResolution {
    let text: String
    let key: HistoricalPnlPeriod

    static var allResolutions: [PortfolioChartResolution] {
        [
            PortfolioChartResolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.1D"), key: .period1d),
            PortfolioChartResolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.7D"), key: .period7d),
            PortfolioChartResolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.30D"), key: .period30d),
            PortfolioChartResolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.90D"), key: .period90d)
        ]
    }
}
