//
//  SharedMarketPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/3/22.
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

protocol SharedMarketPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: SharedMarketViewModel? { get }
}

class SharedMarketPresenter: HostedViewPresenter<SharedMarketViewModel>, SharedMarketPresenterProtocol {
    @Published var marketId: String?

    override init() {
        super.init()

        viewModel = SharedMarketViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(AbacusStateManager.shared.state.marketMap,
                           AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] (marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) in
                guard let marketId = self?.marketId,
                        let market = marketMap[marketId] else { return }

                let asset = assetMap[market.assetId]
                self?.viewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
            }
            .store(in: &subscriptions)
    }

    static func createViewModel(market: PerpetualMarket, asset: Asset?) -> SharedMarketViewModel {
        let viewModel = SharedMarketViewModel()
        viewModel.assetId = asset?.displayableAssetId ?? market.assetId
        viewModel.assetName = asset?.name ?? market.displayId
        if let imageUrl = asset?.resources?.imageUrl {
            viewModel.logoUrl = URL(string: imageUrl)
        }
        viewModel.volume24H = dydxFormatter.shared.dollarVolume(number: market.perpetual?.volume24H)
        let tickSize = market.configs?.displayTickSizeDecimals?.intValue ?? 2
        let price = market.oraclePrice?.doubleValue
        viewModel.indexPrice = dydxFormatter.shared.dollar(number: price, digits: tickSize)
        if let priceChangePercent24H = dydxFormatter.shared.percent(number: abs(market.priceChange24HPercent?.doubleValue ?? 0), digits: 2) {
            viewModel.priceChangePercent24H = SignedAmountViewModel(text: priceChangePercent24H,
                                                                    sign: market.priceChange24HPercent?.doubleValue ?? 0 >= 0 ? .plus : .minus,
                                                                    coloringOption: .allText)
        }
        // sometimes the descriptions are unavailable, need to check localized output to ensure availability
        if let key = asset?.resources?.primaryDescriptionKey,
           DataLocalizer.localize(path: "APP.\(key)") != "APP.\(key)" {
            viewModel.primaryDescription = DataLocalizer.localize(path: "APP.\(key)")
        }
        if let key = asset?.resources?.secondaryDescriptionKey,
           DataLocalizer.localize(path: "APP.\(key)") != "APP.\(key)" {
            viewModel.secondaryDescription = DataLocalizer.localize(path: "APP.\(key)")
        }
        if let websiteLink = asset?.resources?.websiteLink {
            viewModel.websiteUrl = URL(string: websiteLink)
        }
        if let whitepaperLink = asset?.resources?.whitepaperLink {
            viewModel.whitepaperUrl = URL(string: whitepaperLink)
        }
        if let coinMarketCapsLink = asset?.resources?.coinMarketCapsLink {
            viewModel.coinMarketPlaceUrl = URL(string: coinMarketCapsLink)
        }
        return viewModel
    }
}
