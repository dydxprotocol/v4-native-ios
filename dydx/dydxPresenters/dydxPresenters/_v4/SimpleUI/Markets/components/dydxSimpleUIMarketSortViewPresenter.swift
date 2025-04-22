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
    case price, volume, gainers, losers, favorites
}

protocol dydxSimpleUIMarketSortViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketSortViewModel? { get }
}

class dydxSimpleUIMarketSortViewPresenter: HostedViewPresenter<dydxSimpleUIMarketSortViewModel>, dydxSimpleUIMarketSortViewPresenterProtocol {
    @Published var sortOption: SimpleUIMarketSortOption = .volume {
        didSet {
            updateSortOption()
            SettingsStore.shared?.setValue(sortOption.rawValue, forDydxKey: .simpleUISortOrder)
        }
    }

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketSortViewModel()

        if let simpleUISortOrder = SettingsStore.shared?.value(forDydxKey: .simpleUISortOrder) as? String {
            sortOption = SimpleUIMarketSortOption(rawValue: simpleUISortOrder) ?? .volume
        }
    }

    override func start() {
        super.start()

        updateSortOption()
    }

    private func updateSortOption() {
        viewModel?.items = [
            .init(icon: "icon_sort_price",
                  title: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                  selected: sortOption == .price,
                  action: { [weak self] in
                self?.sortOption = .price
            }),
            .init(icon: "icon_sort_volume",
                  title: DataLocalizer.localize(path: "APP.TRADE.VOLUME"),
                  selected: sortOption == .volume,
                  action: { [weak self] in
                self?.sortOption = .volume
            }),
            .init(icon: "icon_sort_gainer",
                  title: DataLocalizer.localize(path: "APP.GENERAL.GAINERS"),
                  subtitle: "(" + DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS._24H") + ")",
                  selected: sortOption == .gainers,
                  action: { [weak self] in
                self?.sortOption = .gainers
            }),
            .init(icon: "icon_sort_loser",
                  title: DataLocalizer.localize(path: "APP.GENERAL.LOSERS"),
                  subtitle: "(" + DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS._24H") + ")",
                  selected: sortOption == .losers,
                  action: { [weak self] in
                self?.sortOption = .losers
            }),
            .init(icon: "icon_sort_favorite",
                  title: DataLocalizer.localize(path: "APP.GENERAL.FAVORITES"),
                  selected: sortOption == .favorites,
                  action: { [weak self] in
                self?.sortOption = .favorites
            })
        ]
    }
}
