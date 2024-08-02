//
//  dydxAssetItemChartViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/5/22.
//

import Utilities
import dydxViews
import PlatformParticles
import ParticlesKit
import Abacus
import dydxStateManager
import Combine
import DGCharts
import PlatformUI
import dydxChart

// MARK: Asset Item Candle Chart

protocol dydxAssetItemChartViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxChartViewModel? { get }
}

class dydxAssetItemChartViewPresenter: HostedViewPresenter<dydxChartViewModel>, dydxAssetItemChartViewPresenterProtocol {
    private let lineChartView = LineChartView()
    private let listPresenter = LineGraphingListPresenter()
    private let lineGraphingPresenter = LineGraphingPresenter()

    @Published var candles: MarketCandles?
    @Published var sparklines: [Double]?
    @Published var priceChange24HPercent: Double?

    override init() {
        super.init()

        viewModel = dydxChartViewModel(chartView: lineChartView)

        lineGraphingPresenter.chartView = lineChartView
        lineGraphingPresenter.view = lineChartView
        lineGraphingPresenter.presenters = [listPresenter]
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                $sparklines
                    .compactMap { $0 }
                    .removeDuplicates(),
                $priceChange24HPercent
                    .compactMap {
                        ($0 ?? 0) < 0 ? ThemeSettings.negativeColor.uiColor : ThemeSettings.positiveColor.uiColor
                    }
                    .removeDuplicates()
            )
            .sink { (sparklines: [Double], color: UIColor?) in
                self.listPresenter.color = color
                self.updateGraphData(sparklines: sparklines)
            }
            .store(in: &subscriptions)
    }

    private func updateGraphData(sparklines: [Double]) {
        let dataPoints = sparklines.enumerated()
            .map { (index, line) in
                SparklineDataPoint(lineValue: line, index: index)
            }

        let interactor = ListInteractor()
        interactor.list = dataPoints
        listPresenter.interactor = interactor
    }

    private func updateGraphData(candles: MarketCandles) {
        if let candles = candles.candles?[CandleResolution.ONEHOUR.v4Key] {
            let candleDataPoints =
            Array(candles)
                .map { candle in
                    CandleDataPoint(candle: candle, resolution: CandleResolution.ONEHOUR)
                }
            let interactor = ListInteractor()
            interactor.list = candleDataPoints
            listPresenter.interactor = interactor
        }
    }
}
