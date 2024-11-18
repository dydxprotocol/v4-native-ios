//
//  dydxOrderbookPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 1/4/23.
//

import Abacus
import Combine
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities
import dydxFormatter

protocol dydxOrderbookPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOrderbookViewModel? { get }
}

class dydxOrderbookPresenter: HostedViewPresenter<dydxOrderbookViewModel>, dydxOrderbookPresenterProtocol {
    struct ColorMapEntry {
        let date: Date
        let size: Double
    }
    @Published var display: OrderbookDisplay = .all
    @Published var marketId: String?

    private var asksColorMap: [Double: ColorMapEntry]?
    private var bidsColorMap: [Double: ColorMapEntry]?
    private let colorChangeTime: TimeInterval = 0.2 // time to change the color of the new entries

    override init() {
        super.init()
        viewModel = dydxOrderbookViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4(
                $marketId,
                AbacusStateManager.shared.state.marketMap,
                AbacusStateManager.shared.state.orderbooksMap,
                Timer.publish(every: colorChangeTime, on: .main, in: .default).autoconnect()
            )
            .sink { [weak self] marketId, marketMap, orderbooksMap, _ in
                if let marketId = marketId {
                    let market = marketMap[marketId]
                    let orderbook = orderbooksMap[marketId]
                    self?.update(market: market, orderbook: orderbook)
                } else {
                    self?.update(market: nil, orderbook: nil)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(market: PerpetualMarket?, orderbook: MarketOrderbook?) {
        var maxDepthForAsks: Double?
        var maxDepthForBids: Double?
        let tickSize = dydxFormatter.shared.format(decimal: orderbook?.grouping?.tickSize?.decimalValue)
        if display == .all || display == .asks {
            viewModel?.asks?.tickSize = tickSize
            let (asks, maxDepth) = filterOrderbookLines(lines: orderbook?.asks, market: market, colorMap: &asksColorMap, textColor: ThemeSettings.negativeColor)
            viewModel?.asks?.lines = asks
            maxDepthForAsks = maxDepth
        } else {
            viewModel?.asks = nil
        }

        if display == .all || display == .bids {
            viewModel?.bids?.tickSize = tickSize
            let (bids, maxDepth) = filterOrderbookLines(lines: orderbook?.bids, market: market, colorMap: &bidsColorMap, textColor: ThemeSettings.positiveColor)
            viewModel?.bids?.lines = bids
            maxDepthForBids = maxDepth
        } else {
            viewModel?.bids = nil
        }

        let maxDepth = max(maxDepthForAsks ?? 0, maxDepthForBids ?? 0)
        viewModel?.asks?.maxDepth = maxDepth
        viewModel?.bids?.maxDepth = maxDepth

        viewModel?.spread?.percent = orderbook?.spreadPercent?.doubleValue ?? 0.0
    }

    private func filterOrderbookLines(lines: [OrderbookLine]?, market: PerpetualMarket?, colorMap: inout [Double: ColorMapEntry]?, textColor: ThemeColor.SemanticColor) -> ([dydxOrderbookLine], Double) {
        var maxDepth: Double = 0.0
        var newColorMap = [Double: ColorMapEntry]()
        var output = [dydxOrderbookLine]()
        let maxLinesToDisplay = 12  // no need to do extra processing. Even on biggest screen, max displayed is ~10
        if let lines = lines {
            let array = Array(lines.prefix(maxLinesToDisplay))
            for i in 0 ..< array.count {
                let line = array[i]
                let depth = (line.depth?.doubleValue ?? 0)
                if depth > maxDepth {
                    maxDepth = depth
                }

                let changedTextColor: ThemeColor.SemanticColor
                let now = Date()
                if let entry = colorMap?[line.price] {
                    if now.timeIntervalSince(entry.date) < colorChangeTime {
                        changedTextColor = textColor
                        newColorMap[line.price] = entry
                    } else if line.size != entry.size {
                        changedTextColor = textColor
                        newColorMap[line.price] = ColorMapEntry(date: now, size: line.size)
                    } else {
                        changedTextColor = .textSecondary
                        newColorMap[line.price] = entry
                    }
                } else {
                    changedTextColor = textColor
                    newColorMap[line.price] = ColorMapEntry(date: now, size: line.size)
                }

                output.append(orderbookLine(line: line, market: market, textColor: changedTextColor))
            }
        }
        colorMap = newColorMap
        return (output, maxDepth)
    }

    private func orderbookLine(line: OrderbookLine, market: PerpetualMarket?, textColor: ThemeColor.SemanticColor) -> dydxOrderbookLine {
        let sizeText = dydxFormatter.shared.raw(number: NSNumber(value: line.size), digits: market?.configs?.displayStepSizeDecimals?.intValue ?? 4) ?? ""
        return dydxOrderbookLine(price: line.price,
                                 size: line.size,
                                 sizeText: sizeText,
                                 depth: line.depth?.doubleValue,
                                 taken: nil,
                                 textColor: textColor)
    }
}
