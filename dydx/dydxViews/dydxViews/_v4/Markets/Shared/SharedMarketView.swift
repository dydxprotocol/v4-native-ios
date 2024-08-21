//
//  SharedMarketView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/3/22.
//

import SwiftUI
import PlatformUI
import Utilities

public final class SharedMarketViewModel: PlatformViewModel, Equatable {
    @Published public var assetId: String?
    @Published public var assetName: String?
    @Published public var logoUrl: URL?
    @Published public var volume24H: String?
    @Published public var indexPrice: String?
    @Published public var priceChangePercent24H: SignedAmountViewModel?

    @Published public var primaryDescription: String?
    @Published public var secondaryDescription: String?
    @Published public var whitepaperUrl: URL?
    @Published public var websiteUrl: URL?
    @Published public var coinMarketPlaceUrl: URL?

    public init() { }

    public static var previewValue: SharedMarketViewModel = {
        let vm = SharedMarketViewModel()
        vm.assetId = "ETH"
        vm.assetName = "Ethereum"
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.volume24H = "$223M"
        vm.indexPrice = "$1.00"
        vm.priceChangePercent24H = SignedAmountViewModel(text: "0.2%",
                                                         sign: .plus, coloringOption: .allText)
        vm.primaryDescription = "Ethereum is a global, open-source platform for decentralized applications."
        vm.secondaryDescription = "Ethereum is a decentralized blockchain platform founded in 2014. Ethereum is an open-source project that is not owned or operated by a single individual. This means that anyone, anywhere can download the software and begin interacting with the network. Ethereum allows developers to make and operate 'smart contracts', a core piece of infrastructure for any decentralized application."
        vm.websiteUrl = URL(string: "https://www.getmonero.org/")
        vm.whitepaperUrl = URL(string: "https://www.getmonero.org/resources/research-lab/")
        vm.coinMarketPlaceUrl = URL(string: "https://coinmarketcap.com/currencies/monero/")

        return vm
    }()

    public static func == (lhs: SharedMarketViewModel, rhs: SharedMarketViewModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.assetId == rhs.assetId &&
        lhs.assetName == rhs.assetName &&
        lhs.logoUrl == rhs.logoUrl &&
        lhs.volume24H == rhs.volume24H &&
        lhs.indexPrice == rhs.indexPrice &&
        lhs.priceChangePercent24H == rhs.priceChangePercent24H &&
        lhs.primaryDescription == rhs.primaryDescription &&
        lhs.secondaryDescription == rhs.secondaryDescription &&
        lhs.websiteUrl == rhs.websiteUrl &&
        lhs.whitepaperUrl == rhs.whitepaperUrl &&
        lhs.coinMarketPlaceUrl == rhs.coinMarketPlaceUrl
    }
}
