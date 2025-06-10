//
//  dydxSimpleUIPositionsToggleViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/06/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

enum SimpleUIPositionToggleOption: String, CaseIterable {
    case price, pnl, marginUsage

    var viewOption: dydxSimpleUIMarketViewModel.PositionToggleType {
        switch self {
        case .price:
            return .price
        case .pnl:
            return .pnl
        case .marginUsage:
            return .marginUsage
        }
    }
}

final class SimpleUIPositionToggleOptionState: SingletonProtocol {
    static var shared = SimpleUIPositionToggleOptionState()

    init() {
        if let value = SettingsStore.shared?.value(forDydxKey: .simpleUIPositionToggle) as? String {
            current = SimpleUIPositionToggleOption(rawValue: value) ?? .pnl
        }
    }

    @Published var current: SimpleUIPositionToggleOption = .pnl {
        didSet {
            SettingsStore.shared?.setValue(current.rawValue, forDydxKey: .simpleUIPositionToggle)
        }
    }
}

protocol dydxSimpleUIPositionsToggleViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIPositionsToggleViewModel? { get }
}

final class dydxSimpleUIPositionsToggleViewPresenter: HostedViewPresenter<dydxSimpleUIPositionsToggleViewModel>, dydxSimpleUIPositionsToggleViewPresenterProtocol {

    override init() {
        super.init()

        viewModel = dydxSimpleUIPositionsToggleViewModel()
    }

    override func start() {
        super.start()

        SimpleUIPositionToggleOptionState.shared.$current
            .sink { [weak self] option in
                self?.updateToggleOption(toggleOption: option)
            }
            .store(in: &subscriptions)
    }

    private func updateToggleOption(toggleOption: SimpleUIPositionToggleOption) {
        viewModel?.items = [
            .init(icon: "icon_price",
                  title: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                  selected: toggleOption == .price,
                  action: {
                      SimpleUIPositionToggleOptionState.shared.current = .price
                  }),
            .init(icon: "icon_pnl",
                  title: DataLocalizer.localize(path: "APP.GENERAL.PNL"),
                  selected: toggleOption == .pnl,
                  action: {
                      SimpleUIPositionToggleOptionState.shared.current = .pnl
                  }),
            .init(icon: "icon_margin_usage",
                  title: DataLocalizer.localize(path: "APP.GENERAL.MARGIN_USAGE"),
                  selected: toggleOption == .marginUsage,
                  action: {
                      SimpleUIPositionToggleOptionState.shared.current = .marginUsage
                  })
        ]
    }
}
