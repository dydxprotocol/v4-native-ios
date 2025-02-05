//
//  dydxSimpleUiMarketLaunchableViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 01/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import dydxStateManager
import Abacus
import dydxFormatter
import SwiftUI
import Statsig

protocol dydxSimpleUiMarketLaunchableViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUiMarketLaunchableViewModel? { get }
}

class dydxSimpleUiMarketLaunchableViewPresenter: HostedViewPresenter<dydxSimpleUiMarketLaunchableViewModel>, dydxSimpleUiMarketLaunchableViewPresenterProtocol {
    @Published var marketId: String?

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        super.init()

        $marketId.assign(to: &marketPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4($marketId,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.vault,
                            marketPresenter.$viewModel)
            .sink { [weak self] marketId, marketMap, vault, marketViewModel in
                guard let marketId, let market = marketMap[marketId] else {
                    return
                }
                if market.isLaunched {
                    self?.viewModel = nil
                } else {
                    self?.viewModel = self?.createViewModel(market: market, vault: vault, marketViewModel: marketViewModel)
                }
            }
            .store(in: &subscriptions)
    }

    private func createViewModel(market: PerpetualMarket, vault: Vault?, marketViewModel: SharedMarketViewModel?) -> dydxSimpleUiMarketLaunchableViewModel {
        let viewModel = dydxSimpleUiMarketLaunchableViewModel()
        viewModel.sharedMarketViewModel = marketViewModel
        viewModel.ctaAction = {
            let urlString = "\(AbacusStateManager.shared.deploymentUri)/trade/\(market.id)"
            if let url = URL(string: urlString) {
                if URLHandler.shared?.canOpenURL(url) ?? false {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }

        viewModel.minDeposit = dydxNumberFeatureFlag.min_deposit_for_launchable_market.value
        viewModel.thirtyDayReturnPercent = vault?.details?.thirtyDayReturnPercent?.doubleValue

        viewModel.faqAction = {
            if let urlString = AbacusStateManager.shared.environment?.links?.vaultLearnMore,
               let url = URL(string: urlString) {
                if URLHandler.shared?.canOpenURL(url) ?? false {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }

        return viewModel
    }
}
