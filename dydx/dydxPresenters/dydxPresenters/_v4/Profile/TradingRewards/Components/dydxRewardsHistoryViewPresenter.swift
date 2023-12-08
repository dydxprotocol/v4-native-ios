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
            case .monthly: return DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.MONTHLY", params: nil)
            case .weekly: return DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.WEEKLY", params: nil)
            case .daily: return DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.DAILY", params: nil)
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
            // TODO filter abacus results by period
//            Router.shared?.navigate(to: .init(url: ...), animated: true, completion: nil)
        }

        // TODO get todos from abacus
        viewModel?.items = [
            .init(period: "period 1 -> period 2", amount: "1.000"),
            .init(period: "period 2 -> period 3", amount: "2.000"),
            .init(period: "period 3 -> period 4", amount: "3.000"),
            .init(period: "period 4 -> period 5", amount: "4.000"),
            .init(period: "period 5 -> period 6", amount: "5.000"),
            .init(period: "period 6 -> period 7", amount: "6.000"),
            .init(period: "period 7 -> period 8", amount: "7.000"),
            .init(period: "period 8 -> period 9", amount: "8.000"),
            .init(period: "period 9 -> period 10", amount: "9.000"),
            .init(period: "period 10 -> period 11", amount: "10.000"),
            .init(period: "period 11 -> period 12", amount: "11.000"),
            .init(period: "period 12 -> period 2", amount: "1.000"),
            .init(period: "period 13 -> period 3", amount: "2.000"),
            .init(period: "period 14 -> period 4", amount: "3.000"),
            .init(period: "period 15 -> period 5", amount: "4.000"),
            .init(period: "period 16 -> period 6", amount: "5.000"),
            .init(period: "period 17 -> period 7", amount: "6.000"),
            .init(period: "period 18 -> period 8", amount: "7.000"),
            .init(period: "period 19 -> period 9", amount: "8.000"),
            .init(period: "period 20 -> period 10", amount: "9.000"),
            .init(period: "period 21 -> period 11", amount: "10.000"),
            .init(period: "period 22 -> period 3", amount: "2.000"),
            .init(period: "period 23 -> period 4", amount: "3.000"),
            .init(period: "period 24 -> period 5", amount: "4.000"),
            .init(period: "period 25 -> period 6", amount: "5.000"),
            .init(period: "period 26 -> period 7", amount: "6.000"),
            .init(period: "period 27 -> period 8", amount: "7.000"),
            .init(period: "period 28 -> period 9", amount: "8.000"),
            .init(period: "period 29 -> period 10", amount: "9.000")
        ]
    }
}
