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
    private let favoritePresenter = dydxUserFavoriteViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter,
        favoritePresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketInfoHeaderViewModel()

        marketPresenter.$viewModel.assign(to: &viewModel.$sharedMarketViewModel)
        favoritePresenter.$viewModel.assign(to: &viewModel.$favoriteViewModel)

        super.init()

        self.viewModel = viewModel

        viewModel.onBackButtonTap = { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        $marketId.assign(to: &marketPresenter.$marketId)
        $marketId.assign(to: &favoritePresenter.$marketId)

        attachChildren(workers: childPresenters)
     }
}
