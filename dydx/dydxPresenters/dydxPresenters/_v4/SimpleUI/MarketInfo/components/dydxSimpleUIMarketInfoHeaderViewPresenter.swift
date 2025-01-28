//
//  dydxSimpleUIMarketInfoHeaderViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxSimpleUIMarketInfoHeaderViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketInfoHeaderViewModel? { get }
}

class dydxSimpleUIMarketInfoHeaderViewPresenter: HostedViewPresenter<dydxSimpleUIMarketInfoHeaderViewModel>, dydxSimpleUIMarketInfoHeaderViewPresenterProtocol {
    @Published var marketId: String?

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketInfoHeaderViewModel()

        marketPresenter.$viewModel.assign(to: &viewModel.$sharedMarketViewModel)

        super.init()

        self.viewModel = viewModel

        viewModel.onBackButtonTap = { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        $marketId.assign(to: &marketPresenter.$marketId)

        attachChildren(workers: childPresenters)
     }
}
