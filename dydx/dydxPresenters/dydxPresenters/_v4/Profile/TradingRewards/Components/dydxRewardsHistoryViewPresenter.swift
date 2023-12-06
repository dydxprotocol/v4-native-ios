//
//  dydxRewardsHistoryViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 12/6/23.
//

import dydxViews
import PlatformParticles
import ParticlesKit
import RoutingKit
import Utilities

public protocol dydxRewardsHistoryViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsHistoryViewModel? { get }
}

public class dydxRewardsHistoryViewPresenter: HostedViewPresenter<dydxRewardsHistoryViewModel>, dydxRewardsHistoryViewPresenterProtocol {

    enum Period: CaseIterable {
        case monthly
        case weekly
        case daily

        var text: String? {
            switch self {
            case .monthly: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.MONTHLY", params: nil)
            case .weekly: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.WEEKLY", params: nil)
            case .daily: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.DAILY", params: nil)
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxRewardsHistoryViewModel()

        viewModel?.filters = Period.allCases.compactMap { period in
            guard let text = period.text else { return nil }
            return .text(text)
        }

        viewModel?.onSelectionChanged = { index in
            let period = Period.allCases[index]
            // TODO get url from abacus
//            Router.shared?.navigate(to: .init(url: ...), animated: true, completion: nil)
        }

        // TODO get todos from abacus
        viewModel?.items = [

        ]
    }
}
