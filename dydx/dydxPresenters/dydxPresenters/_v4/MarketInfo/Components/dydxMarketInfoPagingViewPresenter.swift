//
//  dydxMarketInfoPagingViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/10/22.
//

import Abacus
import Combine
import dydxFormatter
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities

protocol dydxMarketInfoPagingViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketInfoPagingViewModel? { get }
}

class dydxMarketInfoPagingViewPresenter: HostedViewPresenter<dydxMarketInfoPagingViewModel>, dydxMarketInfoPagingViewPresenterProtocol {
    @Published var marketId: String?

    private let accountPresenter = SharedAccountPresenter()
    private let candlesViewPresenter = dydxMarketPriceCandlesViewPresenter()
    private let depthViewPresenter = dydxMarketDepthChartViewPresenter()
    private let fundingViewPresenter = dydxMarketFundingChartViewPresenter()
    private let tradesViewPresenter = dydxMarketTradesViewPresenter()
    private let orderbookPresenter = dydxMarketOrderbookPresenter()

    private var isAccountVisible = false {
        didSet {
            if isAccountVisible != oldValue {
                updateTiles()
            }
        }
    }

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        accountPresenter,
        candlesViewPresenter,
        depthViewPresenter,
        fundingViewPresenter,
        orderbookPresenter,
        tradesViewPresenter
    ]

    private var tiles: [MarketInfoPagingTile] {
        if dydxBoolFeatureFlag.enable_spot_experience.isEnabled {
            return [
                MarketInfoPagingTile(type: .price,
                                     text: DataLocalizer.localize(path: "APP.GENERAL.PRICE_CHART_SHORT"),
                                     icon: UIImage.named("icon_market_price", bundles: Bundle.particles) ?? UIImage())
            ]
                .filterNils()
        } else {
            return [
                isAccountVisible ?
                MarketInfoPagingTile(type: .account,
                                     text: DataLocalizer.localize(path: "APP.GENERAL.ACCOUNT"),
                                     icon: UIImage.named("icon_market_wallet", bundles: Bundle.particles) ?? UIImage()) :
                    nil,
                MarketInfoPagingTile(type: .price,
                                     text: DataLocalizer.localize(path: "APP.GENERAL.PRICE_CHART_SHORT"),
                                     icon: UIImage.named("icon_market_price", bundles: Bundle.particles) ?? UIImage()),
                MarketInfoPagingTile(type: .depth,
                                     text: DataLocalizer.localize(path: "APP.GENERAL.DEPTH_CHART_SHORT"),
                                     icon: UIImage.named("icon_market_depth", bundles: Bundle.particles) ?? UIImage()),
                MarketInfoPagingTile(type: .funding,
                                     text: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"),
                                     icon: UIImage.named("icon_market_funding", bundles: Bundle.particles) ?? UIImage()),
                MarketInfoPagingTile(type: .orderbook,
                                     text: DataLocalizer.localize(path: "APP.TRADE.ORDERBOOK_SHORT"),
                                     icon: UIImage.named("icon_market_book", bundles: Bundle.particles) ?? UIImage()),
                MarketInfoPagingTile(type: .recent,
                                     text: DataLocalizer.localize(path: "APP.GENERAL.RECENT"),
                                     icon: UIImage.named("icon_market_recent", bundles: Bundle.particles) ?? UIImage())
            ]
                .filterNils()
        }
    }

    override init() {
        let viewModel = dydxMarketInfoPagingViewModel()

        // Account
        accountPresenter.$viewModel.assign(to: &viewModel.account.$sharedAccountViewModel)
        // Candle
        candlesViewPresenter.$viewModel.assign(to: &viewModel.$priceCandles)
        // Depth
        depthViewPresenter.$viewModel.assign(to: &viewModel.$depth)
        // Funding
        fundingViewPresenter.$viewModel.assign(to: &viewModel.$funding)
        // Trades
        tradesViewPresenter.$viewModel.assign(to: &viewModel.$trades)
        // Orderbook
        orderbookPresenter.$viewModel.assign(to: &viewModel.$orderbook)

        super.init()

        self.viewModel = viewModel

        updateTiles()
    }

    override func start() {
        super.start()

        accountPresenter.start()

        $marketId
            .sink { [weak self] marketId in
                self?.candlesViewPresenter.marketId = marketId
                self?.depthViewPresenter.marketId = marketId
                self?.fundingViewPresenter.marketId = marketId
                self?.tradesViewPresenter.marketId = marketId
                self?.orderbookPresenter.marketId = marketId
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] wallet in
                self?.isAccountVisible = wallet != nil
            }
            .store(in: &subscriptions)

        resetPresentersForVisibilityChange()
    }

    private func resetPresentersForVisibilityChange() {
        for i in 0 ..< childPresenters.count {
            if i == viewModel?.tileSelection {
                if childPresenters[i].isStarted == false {
                    childPresenters[i].start()
                }
            } else if childPresenters[i].isStarted, i != 0 {
                childPresenters[i].stop()
            }
        }
    }

    private func updateTiles() {
        // Tiles
        viewModel?.tiles.allTiles = tiles.compactMap { tile in
            dydxMarketTilesViewModel.TileViewModel(text: tile.text,
                                                   icon: .uiImage(image: tile.icon))
        }
        viewModel?.tiles.currentTile = isAccountVisible ? 1 : 0
        viewModel?.tileSelection = 1
        viewModel?.tiles.onSelectionChanged = { [weak self] index in
            self?.viewModel?.tileSelection = (self?.isAccountVisible ?? false) ? index : index + 1
            self?.resetPresentersForVisibilityChange()
        }

        viewModel?.isAccountVisible = isAccountVisible
    }
}

// MARK: Tiles

private struct MarketInfoPagingTile {
    enum TileType: Int {
        case account
        case price
        case depth
        case funding
        case orderbook
        case recent
    }

    let type: TileType
    let text: String
    let icon: UIImage
}
