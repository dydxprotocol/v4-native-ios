//
//  dydxMarketPriceCandlesViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/7/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import DGCharts
import Combine
import dydxFormatter
import dydxChart

protocol dydxMarketPriceCandlesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketPriceCandlesViewModel? { get }
}

class dydxMarketPriceCandlesViewPresenter: HostedViewPresenter<dydxMarketPriceCandlesViewModel>, dydxMarketPriceCandlesViewPresenterProtocol, ChartViewDelegate {
    @Published var marketId: String?
    private var tickSize: Double?

    private let chartView = CombinedChartView()

    private let combinedGraph: CombinedGraphingPresenter = {
        let presenter = CombinedGraphingPresenter()
        presenter.drawBorders = true
        presenter.labelColor = .gray        // TODO
        presenter.drawXAxisText = true
        presenter.drawYAxisText = true
        presenter.drawXAxisLine = true
        presenter.highlightDistance = 0
        presenter.outsideXAxisText = true
        presenter.outsideYAxisText = true
        return presenter
    }()

    private let candlesGraph: CandleStickGraphingListPresenter = {
        let presenter = CandleStickGraphingListPresenter()
        presenter.increasingColor = ThemeSettings.positiveColor.uiColor
        presenter.decreasingColor = ThemeSettings.negativeColor.uiColor
        presenter.neutralColor = ThemeSettings.positiveColor.uiColor
        presenter.color = ThemeSettings.negativeColor.uiColor
        presenter.sequence = 1
        presenter.highlightEnabled = true
        presenter.highlightColor = .gray
        presenter.highlightLineWidth = 0.5
        presenter.highlightDash = 2
        presenter.highlightPhase = 1
        return presenter
    }()

    private let lineGraph: LineGraphingListPresenter = {
        let presenter = LineGraphingListPresenter()
        presenter.color = .gray
        presenter.sequence = 1
        presenter.circleRadius = 2.5
        presenter.circleHoleRadius = 2
        presenter.highlightLineWidth = 0.5
        presenter.highlightEnabled = true
        presenter.highlightColor = .gray
        presenter.highlightPhase = 1
        presenter.highlightDash = 2
        return presenter
    }()

    private let barGraph: BarGraphingListPresenter = {
        let presenter = BarGraphingListPresenter()
        presenter.color = .gray
        presenter.sequence = 2
        presenter.increasingColor = ThemeSettings.positiveColor.uiColor.withAlphaComponent(0.3)
        presenter.decreasingColor = ThemeSettings.negativeColor.uiColor.withAlphaComponent(0.3)
        return presenter
    }()

    private let xAxisFormatter: DateTimeAxisFormatter = {
        let formatter = DateTimeAxisFormatter()
        formatter.type = .day
        formatter.resolution = Resolution.defaultResolution
        return formatter
    }()

    private let yAxisFormatter = PriceAxisFormatter()

    private let listInteractor = ListInteractor()

    @Published private var currentResolutionIndex: Int? {
        didSet {
            if currentResolutionIndex != oldValue {
                if let currentResolutionIndex = currentResolutionIndex {
                    let resolutionKey = Resolution.allResolutions[currentResolutionIndex].key.v4Key
                    AbacusStateManager.shared.setCandlesResolution(candlesResolution: resolutionKey)
                    viewModel?.control.resolutions.value = resolutionKey
                }
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxMarketPriceCandlesViewModel()

        // Control
        viewModel?.control.types.displayTypes = ChartType.displayTypes.map(\.text)
        viewModel?.control.types.onDisplayTypeChanged = { [weak self] index in
            guard let self = self else { return }
            if index < ChartType.displayTypes.count {
                let displayType = ChartType.displayTypes[index]
                switch displayType.typeId {
                case .candles:
                    self.combinedGraph.presenters = [self.candlesGraph, self.barGraph]
                case .line:
                    self.combinedGraph.presenters = [self.lineGraph, self.barGraph]
                }
            }
        }

        viewModel?.control.resolutions.options = Resolution.allResolutions.map { resolution in
            InputSelectOption(value: resolution.key.v4Key, string: DataLocalizer.localize(path: resolution.text))
        }
        viewModel?.control.resolutions.value = Resolution.defaultResolution.v4Key
        viewModel?.control.resolutions.onEdited = { [weak self] key in
            if let key = key, let resolution = Resolution.withKey(key: key) {
                AbacusStateManager.shared.setCandlesResolution(candlesResolution: resolution.key.v4Key)
                self?.currentResolutionIndex = Resolution.indexOf(key: key)
            }
        }
        currentResolutionIndex = Resolution.defaultResolutionIndex ?? 0

        // Chart
        viewModel?.chart = dydxChartViewModel(chartView: chartView)

        combinedGraph.chartView = chartView
        combinedGraph.xAxisFormatter = xAxisFormatter
        combinedGraph.presenters = [candlesGraph, barGraph]

        candlesGraph.interactor = listInteractor
        lineGraph.interactor = listInteractor
        barGraph.interactor = listInteractor

        chartView.delegate = self
    }

    override func start() {
        super.start()

        let candlesPublisher = $marketId
            .compactMap { $0 }
            .flatMap { AbacusStateManager.shared.state.candles(of: $0) }

        Publishers
            .CombineLatest4($marketId,
                            AbacusStateManager.shared.state.marketMap,
                            candlesPublisher,
                            $currentResolutionIndex.compactMap { $0 })
            .sink { [weak self] marketId, marketMap, candles, resolutionIndex in
                guard let marketId = marketId, let market = marketMap[marketId] else { return }
                self?.tickSize = market.configs?.displayTickSize?.doubleValue
                if let candles = candles {
                    self?.updateGraphData(candles: candles, resolutionIndex: resolutionIndex)
                }
            }
            .store(in: &subscriptions)
    }

    private func updateGraphData(candles: MarketCandles, resolutionIndex: Int) {
        guard resolutionIndex < Resolution.allResolutions.count else {
            listInteractor.list = []
            return
        }
        let resolution = Resolution.allResolutions[resolutionIndex]
        if xAxisFormatter.resolution != resolution.key {
            xAxisFormatter.resolution = resolution.key
        }
        if let candles = candles.candles?[resolution.key.v4Key] {
            let candleDataPoints =
                Array(candles)
                    .map { candle in
                        CandleDataPoint(candle: candle, resolution: resolution.key)
                    }

            listInteractor.list = []        // Needed to ensure the chart reloads properly
            listInteractor.list = candleDataPoints
        } else {
            listInteractor.list = []
        }
    }

    // MARK: ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let tickSize = tickSize,
              let candle = entry.model as? CandleDataPoint  else {
            return
        }

        let size = String(tickSize)
        let sign: PlatformUISign = (candle.candleClose?.doubleValue ?? 0) > (candle.candleOpen?.doubleValue ?? 0) ? .plus : .minus

        var highlights = [dydxMarketPriceCandlesHighlightViewModel.HighlightDataPoint]()
        if let open = candle.candleOpen {
            let value = dydxFormatter.shared.raw(number: open, size: size)
            highlights += [.init(prompt: "O",
                                 amount: SignedAmountViewModel(text: value,
                                                               sign: sign,
                                                               coloringOption: .textOnly))]
        }
        if let high = candle.candleHigh {
            let value = dydxFormatter.shared.raw(number: high, size: size)
            highlights += [.init(prompt: "H",
                                 amount: SignedAmountViewModel(text: value,
                                                               sign: sign,
                                                               coloringOption: .textOnly))]
        }
        if let low = candle.candleLow {
            let value = dydxFormatter.shared.raw(number: low, size: size)
            highlights += [.init(prompt: "L",
                                 amount: SignedAmountViewModel(text: value,
                                                               sign: sign,
                                                               coloringOption: .textOnly))]
        }
        if let close = candle.candleClose {
            let value = dydxFormatter.shared.raw(number: close, size: size)
            highlights += [.init(prompt: "C",
                                 amount: SignedAmountViewModel(text: value,
                                                               sign: sign,
                                                               coloringOption: .textOnly))]
        }
        if let marketCandle = candle.marketCandle {
            let volume = NSNumber(value: marketCandle.baseTokenVolume)
            let value = dydxFormatter.shared.condensed(number: volume, digits: 0)
            highlights += [.init(prompt: "V",
                                 amount: SignedAmountViewModel(text: value,
                                                               sign: sign,
                                                               coloringOption: .textOnly))]
        }

        viewModel?.highlight.dataPoints = highlights
        if let startedAtMilliseconds =  candle.marketCandle?.startedAtMilliseconds {
            viewModel?.highlight.date =  dydxFormatter.shared.dateAndTime(date: Date(milliseconds: startedAtMilliseconds))
        }

        viewModel?.isHighlighted = true
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        viewModel?.isHighlighted = false
    }

}

// MARK: Chart Type

private struct ChartType {
    enum TypeID: Int {
       case candles
       case line
    }

    let text: String
    let typeId: TypeID

    static var displayTypes: [ChartType] {
        [
            ChartType(text: DataLocalizer.localize(path: "APP.GENERAL.CANDLES"), typeId: .candles),
            ChartType(text: DataLocalizer.localize(path: "APP.GENERAL.LINE"), typeId: .line)
        ]
    }
}

// MARK: Resolution

private struct Resolution {
    let text: String
    let key: CandleResolution

    /*
    static func allResolutions(candles: MarketCandles) -> [Resolution] {
        var all = [Resolution]()

        if candles.resolution1Min?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.1MIN"), key: .ONEMIN)]
        }
        if candles.resolution5Mins?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.5MIN"), key: .FIVEMINS)]
        }
        if candles.resolution15Mins?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.15MIN"), key: .FIFTEENMINS)]
        }
        if candles.resolution30Mins?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.30MIN"), key: .THIRTYMINS)]
        }
        if candles.resolution1Hour?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.1H"), key: .ONEHOUR)]
        }
        if candles.resolution4Hours?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.4H"), key: .FOURHOURS)]
        }
        if candles.resolution1Day?.size ?? 0 > 0 {
            all += [Resolution(text: DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.1D"), key: .ONEDAY)]
        }

        return all
    }
     */

    static var allResolutions: [Resolution] {
        var all = [Resolution]()
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.1MIN", key: .ONEMIN)]
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.5MIN", key: .FIVEMINS)]
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.15MIN", key: .FIFTEENMINS)]
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.30MIN", key: .THIRTYMINS)]
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.1H", key: .ONEHOUR)]
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.4H", key: .FOURHOURS)]
        all += [Resolution(text: "APP.GENERAL.TIME_STRINGS.1D", key: .ONEDAY)]
        return all
    }

    static var defaultResolutionIndex: Int? {
        allResolutions.firstIndex { resolution in
            resolution.key == defaultResolution
        }
    }

    static let defaultResolution: CandleResolution = .ONEHOUR

    static func withKey(key: String) -> Resolution? {
        Resolution.allResolutions.first { $0.key.v4Key == key }
    }

    static func indexOf(key: String) -> Int? {
        Resolution.allResolutions.firstIndex { $0.key.v4Key == key }
    }
}
