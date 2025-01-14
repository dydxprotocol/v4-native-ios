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
import DGCharts
import dydxFormatter

protocol dydxPortfolioChartViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioChartViewModel? { get }
}

class dydxPortfolioChartViewPresenter: HostedViewPresenter<dydxPortfolioChartViewModel>, dydxPortfolioChartViewPresenterProtocol, ChartViewDelegate {

    private let chartView = LineChartView()

    private lazy var linePresenter: LineGraphingListPresenter = {
        let presenter = LineGraphingListPresenter()
        presenter.color = ThemeSettings.positiveColor.uiColor
        presenter.sequence = 0
        presenter.increasingColor = ThemeSettings.positiveColor.uiColor
        presenter.decreasingColor = ThemeSettings.negativeColor.uiColor
        presenter.highlightColor = .gray
        presenter.highlightLineWidth = 0.5
        presenter.highlightPhase = 1
        presenter.highlightEnabled = true
        presenter.highlightDash = 2
        presenter.smooth = true
        return presenter
    }()

    private lazy var graphPresenter: LineGraphingPresenter = {
        let presenter = LineGraphingPresenter()
        presenter.highlightDistance = 0
        presenter.chartDelegate = self
        presenter.chartView = chartView
        return presenter
    }()

    private let listInteractor = ListInteractor()

    @Published private var selectedChartEntry: ChartDataEntry? {
        didSet {
            if selectedChartEntry !== oldValue {
                if selectedChartEntry === nil || oldValue === nil {
                    HapticFeedback.shared?.impact(level: .high)
                }
            }
        }
    }

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

        // Chart
        viewModel?.chart = dydxChartViewModel(chartView: chartView)

        graphPresenter.chartView = chartView
        graphPresenter.presenters = [linePresenter]

        linePresenter.interactor = listInteractor

        chartView.delegate = self
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
                   self?.listInteractor.list = []
               }
           }
           .store(in: &subscriptions)
    }

    private func updatePNLs(pnls: [SubaccountHistoricalPNL], subaccount: Subaccount, selectedChartEntry: ChartDataEntry?) {

        let dataPoints = pnls.compactMap { HistoricalPNLDataPoint(pnl: $0) }
        if let equity = subaccount.equity?.current?.doubleValue {
            // Add the current PNL
             let lastPoint = SubaccountHistoricalPNL(equity: equity, totalPnl: 0, netTransfers: 0, createdAtMilliseconds: Date().timeIntervalSince1970 * 1000)
            listInteractor.list = dataPoints + [HistoricalPNLDataPoint(pnl: lastPoint)]
        } else {
            listInteractor.list = dataPoints
        }

        let firstEquity = pnls.first?.equity
        let targetEquity: Double?
        if let historicalPNL = (selectedChartEntry?.model as? HistoricalPNLDataPoint)?.historicalPNL {
            targetEquity = historicalPNL.equity
            viewModel?.equity = dydxFormatter.shared.dollar(number: historicalPNL.equity, size: nil)
            viewModel?.equityLabel = Date(milliseconds: historicalPNL.createdAtMilliseconds).localDatetimeString
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

    // MARK: ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        chartView.highlightValue(highlight)
        selectedChartEntry = entry
    }

    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
        selectedChartEntry = nil
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
        selectedChartEntry = nil
    }

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
    }

    // Callbacks when the chart is moved / translated via drag gesture.
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
    }

    // Callbacks when Animator stops animating
    func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator) {
    }
}

// MARK: Resolution

private struct PortfolioChartResolution {
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
