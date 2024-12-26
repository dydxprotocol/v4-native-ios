//
//  dydxSimpleUIMarketCandlesViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxChart
import dydxStateManager
import Abacus
import Combine
import DGCharts

protocol dydxSimpleUIMarketCandlesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketCandlesViewModel? { get }
}

class dydxSimpleUIMarketCandlesViewPresenter: HostedViewPresenter<dydxSimpleUIMarketCandlesViewModel>, dydxSimpleUIMarketCandlesViewPresenterProtocol, ChartViewDelegate {

    @Published var marketId: String?

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
                }
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketCandlesViewModel()

        // Control
        viewModel?.resolutions.resolutions = Resolution.allResolutions.map { resolution in
            DataLocalizer.localize(path: resolution.text)
        }
        viewModel?.resolutions.currentResolution =  Resolution.defaultResolutionIndex ?? 0
        viewModel?.resolutions.onResolutionChanged = { [weak self] idx in
            self?.currentResolutionIndex = idx
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
            .flatMapLatest {
                AbacusStateManager.shared.state.candles(of: $0)
            }
            .compactMap { $0 }
            .removeDuplicates()

        Publishers
            .CombineLatest(candlesPublisher,
                           $currentResolutionIndex.compactMap { $0 })
            .sink { [weak self] candles, resolutionIndex in
                self?.updateGraphData(candles: candles, resolutionIndex: resolutionIndex)
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
            let candleDataPoints = candles
                    .map { candle in
                        CandleDataPoint(candle: candle, resolution: resolution.key)
                    }

             if listInteractor.list as? [CandleDataPoint] != candleDataPoints {
                listInteractor.list = []        // Needed to ensure the chart reloads properly
                listInteractor.list = candleDataPoints
             }
         } else {
            listInteractor.list = []
        }
    }
}
