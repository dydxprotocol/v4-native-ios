//
//  dydxSimpleUIMarketSortViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 21/04/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

enum SimpleUIMarketSortOption: String, CaseIterable {
    case price, volume, gainers, losers, favorites, marketCap

}

final class SimpleUIMarketSortOptionState: SingletonProtocol {
    static var shared = SimpleUIMarketSortOptionState()

    init() {
        if let simpleUISortOrder = SettingsStore.shared?.value(forDydxKey: .simpleUISortOrder) as? String {
            current = SimpleUIMarketSortOption(rawValue: simpleUISortOrder) ?? .marketCap
        }
    }

    @Published var current: SimpleUIMarketSortOption = .marketCap {
        didSet {
            SettingsStore.shared?.setValue(current.rawValue, forDydxKey: .simpleUISortOrder)
        }
    }
}

protocol dydxSimpleUIMarketSortViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketSortViewModel? { get }
}

class dydxSimpleUIMarketSortViewPresenter: HostedViewPresenter<dydxSimpleUIMarketSortViewModel>, dydxSimpleUIMarketSortViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketSortViewModel()
    }

    override func start() {
        super.start()

        SimpleUIMarketSortOptionState.shared.$current
            .sink { [weak self] option in
                self?.updateSortOption(sortOption: option)
            }
            .store(in: &subscriptions)
    }

    private func updateSortOption(sortOption: SimpleUIMarketSortOption) {
        viewModel?.items = [
            .init(icon: "icon_sort_price",
                  title: DataLocalizer.localize(path: "APP.GENERAL.MARKET_CAP"),
                  selected: sortOption == .marketCap,
                  action: {
                      SimpleUIMarketSortOptionState.shared.current = .marketCap
                  }),
            .init(icon: "icon_sort_volume",
                  title: DataLocalizer.localize(path: "APP.TRADE.VOLUME"),
                  selected: sortOption == .volume,
                  action: {
                      SimpleUIMarketSortOptionState.shared.current = .volume
                  }),
            .init(icon: "icon_sort_gainer",
                  title: DataLocalizer.localize(path: "APP.GENERAL.GAINERS"),
                  subtitle: "(" + DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS._24H") + ")",
                  selected: sortOption == .gainers,
                  action: {
                      SimpleUIMarketSortOptionState.shared.current = .gainers
                  }),
            .init(icon: "icon_sort_loser",
                  title: DataLocalizer.localize(path: "APP.GENERAL.LOSERS"),
                  subtitle: "(" + DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS._24H") + ")",
                  selected: sortOption == .losers,
                  action: {
                      SimpleUIMarketSortOptionState.shared.current = .losers
                  }),
            .init(icon: "icon_sort_favorite",
                  title: DataLocalizer.localize(path: "APP.GENERAL.FAVORITES"),
                  selected: sortOption == .favorites,
                  action: {
                      SimpleUIMarketSortOptionState.shared.current = .favorites
                  })
        ]
    }
}
