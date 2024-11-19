//
//  dydxMarketFundingChartViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/11/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import DGCharts
import Combine
import dydxStateManager
import Abacus
import dydxFormatter
import dydxChart

protocol dydxMarketFundingChartViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketFundingChartViewModel? { get }
}

class dydxMarketFundingChartViewPresenter: HostedViewPresenter<dydxMarketFundingChartViewModel>, dydxMarketFundingChartViewPresenterProtocol, GraphingDelegate, ChartViewDelegate {
    @Published var marketId: String?

    private let chartView = LineChartView()

    private lazy var listPresenter: LineGraphingListPresenter = {
        let presenter = LineGraphingListPresenter()
        presenter.color = .gray
        presenter.sequence = 0
        presenter.highlightColor = .lightGray
        presenter.highlightLineWidth = 0.5
        presenter.highlightPhase = 1
        presenter.highlightEnabled = true
        presenter.highlightDash = 2
        presenter.smooth = true
        return presenter
    }()

    private lazy var fundingPresenter: LineGraphingPresenter = {
        let presenter = LineGraphingPresenter()
        presenter.labelColor = .lightGray
        presenter.drawXAxisText = true
        presenter.drawYAxisText = true
        presenter.highlightDistance = 0
        presenter.outsideYAxisText = true
        presenter.xAxisFormatter = xFormatter
        presenter.yAxisFormatter = yFormatter
        return presenter
    }()

    private let listInteractor = ListInteractor()

    private lazy var xFormatter: DateTimeAxisFormatter = {
        let formatter = DateTimeAxisFormatter()
        formatter.type = .hour
        formatter.resolution = .ONEHOUR
        return formatter
    }()

    private let yFormatter = FundingRatePercentAxisFormatter()

    private var selectedDuration: Duration? {
        didSet {
            if selectedDuration != oldValue, let selectedDuration = selectedDuration {
                if yFormatter.duration != selectedDuration.key {
                    yFormatter.duration = selectedDuration.key
                    fundingPresenter.chartView?.notifyDataSetChanged()
                    displayPayment()
                }
            }
        }
    }

    private var nextFundingRate: Double? {
        didSet {
            if nextFundingRate != oldValue {
                displayPayment()
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxMarketFundingChartViewModel()

        viewModel?.durationControl?.durations = Duration.allDurations.map(\.text)
        viewModel?.durationControl?.onDurationChanged = { [weak self] index in
            if index < Duration.allDurations.count {
                self?.selectedDuration = Duration.allDurations[index]
            }
        }
        viewModel?.durationControl?.currentDuration = 0
        selectedDuration = Duration.allDurations[0]

        viewModel?.chart = dydxChartViewModel(chartView: chartView)

        fundingPresenter.chartView = chartView
        fundingPresenter.presenters = [listPresenter]
        fundingPresenter.graphingDelegate = self

        listPresenter.interactor = listInteractor

        chartView.delegate = self
    }

    override func start() {
        super.start()

        let fundingPublisher = $marketId
            .compactMap { $0 }
            .flatMapLatest { AbacusStateManager.shared.state.historicalFundings(of: $0) }
            .compactMap { $0 }

        fundingPublisher
            .sink { [weak self] fundings in
                let list = fundings
                    .compactMap { HistoricalFundingDataPoint(funding: $0) }
                    .sorted { lhs, rhs in
                        lhs.graphingX?.doubleValue ?? 0 < rhs.graphingX?.doubleValue ?? 0
                    }
                self?.listInteractor.list = list
            }
            .store(in: &subscriptions)

        let perpetualPublisher = $marketId
            .compactMap { $0 }
            .flatMapLatest { AbacusStateManager.shared.state.market(of: $0) }
            .compactMap(\.?.perpetual)
            .compactMap { $0 }

        perpetualPublisher
            .sink { [weak self] perpetual in
                self?.nextFundingRate = perpetual.nextFundingRate?.doubleValue
            }
            .store(in: &subscriptions)
    }

    // MARK: GraphingDelegate

    func didLoad(presenter: PlatformParticles.GraphingPresenter, view: DGCharts.ChartViewBase?, data: DGCharts.ChartData?) {
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

    private var selectedChartEntry: ChartDataEntry? {
        didSet {
            didSetSelectedChartEntry(oldValue: oldValue)
        }
    }

    private func didSetSelectedChartEntry(oldValue: ChartDataEntry?) {
        if selectedChartEntry !== oldValue {
            displayPayment()
            if selectedChartEntry === nil || oldValue === nil {
                HapticFeedback.shared?.impact(level: .high)
            }
        }
    }

    private func displayPayment() {
        var rate: Double?
        var date: Date?

        if let selectedChartEntry = selectedChartEntry {
            rate = (selectedChartEntry.model as? HistoricalFundingDataPoint)?.historicalFunding?.rate
            if let effectiveAtMilliseconds = (selectedChartEntry.model as? HistoricalFundingDataPoint)?.historicalFunding?.effectiveAtMilliseconds {
                date = Date(milliseconds: effectiveAtMilliseconds)
            }
        } else {
            rate = nextFundingRate
        }

        if let rateNumber = rate,
           let subtitleText = dydxFormatter.shared.percent(number: funding(payment: NSNumber(value: rateNumber), abs: true), digits: 6) {
            if rateNumber == Double.zero {
                viewModel?.subtitle = ColoredTextModel(text: subtitleText, color: ThemeSettings.positiveColor)
            } else if rateNumber > Double.zero {
                viewModel?.subtitle = ColoredTextModel(text: "+" + subtitleText, color: ThemeSettings.positiveColor)
            } else {
                viewModel?.subtitle = ColoredTextModel(text: "-" + subtitleText, color: ThemeSettings.negativeColor)
            }
        } else {
            viewModel?.subtitle = nil
        }

        if let date = date {
            viewModel?.title = dydxFormatter.shared.dateAndTime(date: date)
        } else {
            switch selectedDuration?.key {
            case .oneHour:
                viewModel?.title = DataLocalizer.localize(path: "APP.TRADE.CURRENT_RATE_1H", params: nil)
            case .eightHour:
                viewModel?.title = DataLocalizer.localize(path: "APP.TRADE.CURRENT_RATE_8H", params: nil)
            case .annualized:
                viewModel?.title = DataLocalizer.localize(path: "APP.TRADE.CURRENT_ANNUALIZED_RATE", params: nil)
            default:
                viewModel?.title = nil
            }
        }
    }

    private func funding(payment: NSNumber?, abs: Bool) -> NSNumber? {
        switch selectedDuration?.key {
        case .oneHour:
            return abs ? payment?.abs() : payment

        case .eightHour:
            if abs {
                if let funding = payment?.abs().doubleValue {
                    return NSNumber(value: funding * 8)
                } else {
                    return nil
                }
            } else {
                if let funding = payment?.doubleValue {
                    return NSNumber(value: funding * 8)
                } else {
                    return nil
                }
            }

        case .annualized:
            if abs {
                if let funding = payment?.abs().doubleValue {
                    return NSNumber(value: funding * 24 * 365)
                } else {
                    return nil
                }
            } else {
                if let funding = payment?.doubleValue {
                    return NSNumber(value: funding * 24 * 365)
                } else {
                    return nil
                }
            }

        default:
            return nil
        }
    }
}

// MARK: Duration

private struct Duration: Equatable {
    let text: String
    let key: FundingDuration

    static let allDurations: [Duration] = [
        Duration(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.1H"), key: .oneHour),
        Duration(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.8H"), key: .eightHour),
        Duration(text: DataLocalizer.localize(path: "APP.TRADE.ANNUALIZED"), key: .annualized)
    ]
}
