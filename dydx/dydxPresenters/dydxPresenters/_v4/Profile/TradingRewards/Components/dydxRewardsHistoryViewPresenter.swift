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
import dydxStateManager
import Abacus
import dydxFormatter

public protocol dydxRewardsHistoryViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsHistoryViewModel? { get }
}

public class dydxRewardsHistoryViewPresenter: HostedViewPresenter<dydxRewardsHistoryViewModel>, dydxRewardsHistoryViewPresenterProtocol {

    private enum Period: CaseIterable {
        case monthly
        case weekly
        case daily

        var historicalMapKey: String {
            switch self {
            case .monthly:
                "MONTHLY"
            case .weekly:
                "WEEKLY"
            case .daily:
                "DAILY"
            }
        }

        var abacusPeriod: Abacus.HistoricalTradingRewardsPeriod {
            switch self {
            case .monthly:
                return .monthly
            case .weekly:
                return .weekly
            case .daily:
                return .daily
            }
        }

        var text: String? {
            switch self {
            case .monthly: return DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.MONTHLY", params: nil)
            case .weekly: return DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.WEEKLY", params: nil)
            case .daily: return DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.DAILY", params: nil)
            }
        }
    }

    @Published private var selectedPeriodIndex: Int = 1
    private var period: Period { Period.allCases[selectedPeriodIndex] }

    override init() {

        let viewModel = dydxRewardsHistoryViewModel()

        viewModel.filters = Period.allCases.compactMap { period in
            guard let text = period.text else { return nil }
            return .text(text)
        }

        super.init()

        $selectedPeriodIndex.assign(to: &viewModel.$currentSelection)

        self.viewModel = viewModel
    }
    public override func start() {
        super.start()

        AbacusStateManager.shared.setHistoricalTradingRewardPeriod(period: self.period.abacusPeriod)
        AbacusStateManager.shared.state.account
            .map(\.?.tradingRewards?.historical)
            .sink { [weak self] historicalRewards in
                self?.viewModel?.onSelectionChanged = {[weak self] index in
                    guard let self = self else { return }
                    self.selectedPeriodIndex = index
                    AbacusStateManager.shared.setHistoricalTradingRewardPeriod(period: self.period.abacusPeriod)
                    self.updateItems(from: historicalRewards)
                }
                self?.updateItems(from: historicalRewards)
            }
            .store(in: &subscriptions)
    }

    private func updateItems(from historicalRewards: [String: [HistoricalTradingReward]]?) {
        viewModel?.items = historicalRewards?[period.historicalMapKey]?
            .map { reward in
                let startedAt = dydxFormatter.shared.millisecondsToDate(reward.startedAtInMilliseconds, format: .MMM_d_yyyy)
                let endedAt = dydxFormatter.shared.millisecondsToDate(reward.endedAtInMilliseconds, format: .MMM_d_yyyy)
                let period = DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.PERIOD", params: ["START": startedAt, "END": endedAt]) ?? ""
                return dydxRewardsRewardViewModel(period: period,
                                           amount: dydxFormatter.shared.raw(number: NSNumber(value: reward.amount), digits: 4) ?? "--")
            } ?? []
    }
}
