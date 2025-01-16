//
//  dydxSimpleUIMarketDetailsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 15/01/2025.
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

protocol dydxSimpleUIMarketDetailsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketDetailsViewModel? { get }
}

class dydxSimpleUIMarketDetailsViewPresenter: HostedViewPresenter<dydxSimpleUIMarketDetailsViewModel>, dydxSimpleUIMarketDetailsViewPresenterProtocol {
    @Published var marketId: String?

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketDetailsViewModel()

        super.init()

        self.viewModel = viewModel

        $marketId.assign(to: &marketPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        marketPresenter.$viewModel
            .sink { [weak self] viewModel in
                self?.viewModel = dydxSimpleUIMarketDetailsViewModel()
                self?.viewModel?.sharedMarketViewModel = viewModel
            }
            .store(in: &subscriptions)
    }
}
