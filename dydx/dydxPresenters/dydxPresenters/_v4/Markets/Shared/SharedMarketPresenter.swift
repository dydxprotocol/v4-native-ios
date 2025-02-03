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
            .CombineLatest4(
                $marketId,
                AbacusStateManager.shared.state.marketMap,
                AbacusStateManager.shared.state.assetMap,
                AbacusStateManager.shared.state.selectedSubaccount)
            .sink { [weak self] marketId, marketMap, assetMap, subaccount in
                guard let marketId = marketId,
                      let market = marketMap[marketId] else { return }

                let asset = assetMap[market.assetId]
                self?.viewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset, subaccount: subaccount)
            }
            .store(in: &subscriptions)
    }

    static func createViewModel(market: PerpetualMarket,
                                asset: Asset?,
                                subaccount: Subaccount?) -> SharedMarketViewModel {
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
        viewModel.openInterest = dydxFormatter.shared.dollarVolume(number: market.perpetual?.openInterest)
        if let nextFundingAtMilliseconds = market.perpetual?.nextFundingAtMilliseconds {
            let nextFundingAt = Date(milliseconds: nextFundingAtMilliseconds.doubleValue)
            viewModel.nextFunding = IntervalTextModel(date: nextFundingAt, direction: .countDown, format: .full)
        } else {
            // With no nextFundingAt, we will just count down to the next hour mark
            viewModel.nextFunding  = IntervalTextModel(date: nil, direction: .countDownToHour, format: .full)
        }
        if let fundingRate = market.perpetual?.nextFundingRate?.doubleValue {
            let percentText = dydxFormatter.shared.percent(number: fundingRate, digits: 6)
            let sign: PlatformUISign
            if fundingRate == 0 {
                sign = .none
            } else if fundingRate > 0 {
                sign = .plus
            } else {
                sign = .minus
            }
            viewModel.fundingRate = SignedAmountViewModel(text: percentText,
                                                          sign: sign,
                                                          coloringOption: .allText,
                                                          noneColor: .textPrimary)
        } else {
            viewModel.fundingRate = nil
        }
        viewModel.isLaunched = market.isLaunched
        viewModel.marketCap = dydxFormatter.shared.dollarVolume(number: market.marketCaps?.doubleValue)
        viewModel.spotVolume24H = dydxFormatter.shared.dollarVolume(number: market.spot24hVolume?.doubleValue)

        let freeCollateral = subaccount?.freeCollateral?.current?.doubleValue ?? 0.0
        let targetLeverage: Double?
        switch market.configs?.perpetualMarketType {
        case .isolated:
            let DEFAULT_TARGET_LEVERAGE = 2.0
            let maxMarketLeverage = market.configs?.maxMarketLeverage ?? 1.0
            targetLeverage = min(DEFAULT_TARGET_LEVERAGE, maxMarketLeverage)
        case .cross:
            targetLeverage =  market.configs?.maxMarketLeverage ?? 1.0
        default:
            targetLeverage = nil
        }
        if let targetLeverage {
            let buyingPower = freeCollateral * targetLeverage
            viewModel.buyingPower = dydxFormatter.shared.dollar(number: buyingPower.filter(filter: .notNegative), digits: 2)
        } else {
            viewModel.buyingPower = nil
        }

        return viewModel
    }
}
