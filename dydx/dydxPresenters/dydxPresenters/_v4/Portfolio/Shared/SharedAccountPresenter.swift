//
//  SharedAccountPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/6/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import dydxFormatter

protocol SharedAccountPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: SharedAccountViewModel? { get }
}

class SharedAccountPresenter: HostedViewPresenter<SharedAccountViewModel>, SharedAccountPresenterProtocol {
    override init() {
        super.init()

        viewModel = SharedAccountViewModel()
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.selectedSubaccount
            .sink { [weak self] account in
                self?.updateDetails(account: account)
            }
            .store(in: &subscriptions)
    }

    private func updateDetails(account: Subaccount?) {
        viewModel = SharedAccountViewModel()

        viewModel?.freeCollateral = dydxFormatter.shared.dollar(number: account?.freeCollateral?.current?.doubleValue, size: nil)

        viewModel?.buyingPower = dydxFormatter.shared.dollar(number: account?.buyingPower?.current?.doubleValue.filter(filter: .notNegative), digits: 2)

        viewModel?.marginUsage = dydxFormatter.shared.percent(number: account?.marginUsage?.current?.doubleValue, digits: 2)

        viewModel?.leverage = dydxFormatter.shared.leverage(number: account?.leverage?.current?.doubleValue)

        viewModel?.equity = dydxFormatter.shared.dollar(number: account?.equity?.current?.doubleValue, digits: 2)

        viewModel?.openInterest = dydxFormatter.shared.dollarVolume(number: account?.notionalTotal?.current?.doubleValue, digits: 2)

        if let margin = account?.marginUsage?.current?.doubleValue {
            viewModel?.marginUsageIcon = MarginUsageModel(percent: margin, displayOption: .iconOnly)
            viewModel?.leverageIcon = LeverageRiskModel(level: LeverageRiskModel.Level(marginUsage: margin), viewSize: 16, displayOption: .iconOnly)
        }
    }
}
