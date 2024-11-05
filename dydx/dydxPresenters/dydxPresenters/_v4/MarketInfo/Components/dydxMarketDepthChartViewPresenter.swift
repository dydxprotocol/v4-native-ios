//
//  dydxMarketDepthChartViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/10/22.
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

protocol dydxMarketDepthViewChartPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketDepthChartViewModel? { get }
}

class dydxMarketDepthChartViewPresenter: HostedViewPresenter<dydxMarketDepthChartViewModel>, dydxMarketDepthViewChartPresenterProtocol, GraphingDelegate, ChartViewDelegate {
    @Published var marketId: String?

    private let chartView = LineChartView()

    private lazy var bidsPresenter: LineGraphingListPresenter = {
        let presenter = LineGraphingListPresenter()
        presenter.label = "Bids"
        presenter.color = ThemeSettings.positiveColor.uiColor
        presenter.sequence = 0
        presenter.drawFilled = true
        presenter.highlightColor = .gray
        presenter.highlightLineWidth = 0.5
        presenter.highlightPhase = 1
        presenter.highlightEnabled = true
        presenter.highlightDash = 2
        presenter.limit = 25
        return presenter
    }()

    private lazy var asksPresenter: LineGraphingListPresenter = {
        let presenter = LineGraphingListPresenter()
        presenter.label = "Asks"
        presenter.color = ThemeSettings.negativeColor.uiColor
        presenter.sequence = 0
        presenter.drawFilled = true
        presenter.highlightColor = .gray
        presenter.highlightLineWidth = 0.5
        presenter.highlightPhase = 1
        presenter.highlightEnabled = true
        presenter.highlightDash = 2
        presenter.limit = 25
        return presenter
    }()

    private lazy var depthPresenter: LineGraphingPresenter = {
        let presenter = LineGraphingPresenter()
        presenter.drawFilled = true
        presenter.labelColor = .gray
        presenter.drawXAxisText = true
        presenter.highlightDistance = 0
        return presenter
    }()

    private let bidsListInteractor = ListInteractor()
    private let asksListInteractor = ListInteractor()

    private var selectedChartEntry: ChartDataEntry? {
        didSet {
            if selectedChartEntry !== oldValue {
                displayHighlight()
                if selectedChartEntry === nil || oldValue === nil {
                    HapticFeedback.shared?.impact(level: .high)
                }
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxMarketDepthChartViewModel()

        viewModel?.chart = dydxChartViewModel(chartView: chartView)

        depthPresenter.chartView = chartView
        depthPresenter.presenters = [bidsPresenter, asksPresenter]
        depthPresenter.graphingDelegate = self

        bidsPresenter.interactor = bidsListInteractor
        asksPresenter.interactor = asksListInteractor

        chartView.delegate = self
    }

    override func start() {
        super.start()

        let orderbookPublisher = $marketId
            .compactMap { $0 }
            .flatMap { AbacusStateManager.shared.state.orderbook(of: $0) }
            .compactMap { $0 }

        bidsListInteractor.list = []
        asksListInteractor.list = []

        orderbookPublisher
            .sink { [weak self] (orderbook: MarketOrderbook) in
                let bidList = orderbook.bids?
                    .compactMap { OrderbookLineDataPoint(line: $0, side: .bids) }
                self?.bidsListInteractor.list = bidList

                let askList = orderbook.asks?
                    .compactMap { OrderbookLineDataPoint(line: $0, side: .asks) }
                self?.asksListInteractor.list = askList
            }
            .store(in: &subscriptions)
    }

    // MARK: ChartViewDelegate

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

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        chartView.highlightValue(highlight)
        let animated = (selectedChartEntry !== nil)
        selectedChartEntry = entry
        moveHighlightAway(x: highlight.xPx, y: highlight.yPx, chartView: chartView, animated: animated)
    }

    // MARK: GraphingDelegate

    func didLoad(presenter: PlatformParticles.GraphingPresenter, view: DGCharts.ChartViewBase?, data: DGCharts.ChartData?) {
        if let dataSet = data?.dataSets, dataSet.count == 2, let entries1 = (dataSet[0] as? ParticlesLineChartDataSet)?.entries.reversed(), let entries2 = (dataSet[1] as? ParticlesLineChartDataSet)?.entries {
            if var highestBid = entries1.first as? ParticlesLineChartDataEntry, var lowestAsk = entries2.first as? ParticlesLineChartDataEntry {
                var highestBidValue = highestBid.x
                var lowestAskValue = lowestAsk.x
                let center = (highestBidValue + lowestAskValue) / 2.0
                /// cliffBid becomes the last bid which is less than 2% further away from the highest bid when iterating bids in greatest -> least order. If no such bid exists, cliffBid is the lowest bid.
                var cliffBid: ParticlesLineChartDataEntry?
                /// cliffAsk becomes the las ask which is less than 2% further away from the lowest ask when iterating asks in least -> greatest order. If no such ask exists, cliffAsk is the highest ask.
                var cliffAsk: ParticlesLineChartDataEntry?

                for item in entries1 {
                    if let entry = item as? ParticlesLineChartDataEntry {
                        if (highestBidValue - entry.x) / highestBidValue > 0.02 {
                            cliffBid = highestBid
                            break
                        } else {
                            highestBid = entry
                            highestBidValue = entry.x
                        }
                    }
                }

                for item in entries2 {
                    if let entry = item as? ParticlesLineChartDataEntry {
                        if (entry.x - lowestAskValue) / lowestAskValue > 0.02 {
                            cliffAsk = lowestAsk
                            break
                        } else {
                            lowestAsk = entry
                            lowestAskValue = entry.x
                        }
                    }
                }

                if cliffBid === nil {
                    cliffBid = entries1.first as? ParticlesLineChartDataEntry
                }
                if cliffAsk === nil {
                    cliffAsk = entries2.last as? ParticlesLineChartDataEntry
                }

                if let cliffBid = cliffBid, let cliffAsk = cliffAsk {
                    let span = cliffAsk.x - cliffBid.x

                    let centerOffsetBySpread = center - span / 2
                    if let lineChartView = view as? LineChartView {
                        // set the visible span to be the distance between cliffs
                        lineChartView.setVisibleXRange(minXRange: span, maxXRange: span)
                        // center the visible span
                        lineChartView.moveViewToX(centerOffsetBySpread)
                        // make the visible span pinch-zoom adjustable
                        lineChartView.setVisibleXRange(minXRange: span / 4, maxXRange: span * 4 )
                    }
                }
            }
        }
    }

    private func moveHighlightAway(x: CGFloat, y: CGFloat, chartView: ChartViewBase, animated: Bool) {
        let point = CGPoint(x: x, y: y)
        let translated = point // chartView.convert(point, to: view)

        let highlightFrameWidth = viewModel?.hightlight?.width ?? 0
        let highlightFrameHeight = viewModel?.hightlight?.height ?? 0

        let viewSize = CGSize(width: UIScreen.main.bounds.width, height: viewModel?.height ?? 0)

        var targetX = x
        var targetY = y
        if translated.x > viewSize.width / 2 {
            targetX = max(x - highlightFrameWidth - 8, 16)
        } else {
            targetX = min(x + 8, viewSize.width - highlightFrameWidth - 16)
        }
        targetY = viewSize.height / 2 - highlightFrameHeight / 2
        if targetY < 16 {
            targetY = 16
        } else if targetY + highlightFrameHeight > viewSize.height - 16 {
            targetY = viewSize.height - 16 - highlightFrameHeight
        }
        viewModel?.hightlightX = targetX
        viewModel?.hightlightY = targetY
    }

    private func displayHighlight() {
        if let entry = selectedChartEntry,
            let orderDataPoint = entry.model as? OrderbookLineDataPoint,
            let order = orderDataPoint.orderbookLine {

            viewModel?.hightlight = viewModel?.hightlight ?? dydxMarketDepthHightlightViewModel()

            let marketPublisher = $marketId
                .compactMap { $0 }
                .flatMap { AbacusStateManager.shared.state.market(of: $0) }
                .compactMap { $0 }

            Publishers
                .CombineLatest(marketPublisher,
                               AbacusStateManager.shared.state.assetMap)
                .sink { [weak self] (market: PerpetualMarket, assetMap: [String: Asset]) in
                    let asset = assetMap[market.assetId]
                    self?.viewModel?.hightlight?.token = TokenTextViewModel(symbol: asset?.displayableAssetId ?? "-")
                    let tickSize = market.configs?.displayTickSizeDecimals?.intValue ?? 2
                    let stepSize = market.configs?.displayStepSizeDecimals?.intValue ?? 1
                    self?.viewModel?.hightlight?.price = dydxFormatter.shared.dollar(number: NSNumber(value: order.price), digits: tickSize)
                    self?.viewModel?.hightlight?.size = dydxFormatter.shared.localFormatted(number: NSNumber(value: order.size), digits: stepSize)
                    self?.viewModel?.hightlight?.cost = dydxFormatter.shared.dollar(number: NSNumber(value: order.depthCost), digits: 2)    // This is total cost, always round to cents
                    self?.viewModel?.hightlight?.impact = dydxFormatter.shared.percent(number: self?.priceImpact(orderDataPoint: orderDataPoint), digits: 2)

                    switch orderDataPoint.side {
                    case .bids:
                        self?.viewModel?.hightlight?.state = .bids
                    case .asks:
                        self?.viewModel?.hightlight?.state = .asks
                    }
                }
                .store(in: &subscriptions)
        } else {
            viewModel?.hightlight = nil
        }
    }

    private func priceImpact(orderDataPoint: OrderbookLineDataPoint) -> NSNumber? {
        if let best = (orderDataPoint.side == .asks) ? asksListInteractor.list?.first : bidsListInteractor.list?.first,
           let best = best as? OrderbookLineDataPoint,
           let bestPrice = best.orderbookLine?.price,
           let price = orderDataPoint.orderbookLine?.price {
            return NSNumber(value: abs(price - bestPrice) / bestPrice)
        } else {
            return nil
        }
    }
}
