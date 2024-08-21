//
//  dydxUserFavoriteViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/4/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxUserFavoriteViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxUserFavoriteViewModel? { get }
}

class dydxUserFavoriteViewPresenter: HostedViewPresenter<dydxUserFavoriteViewModel>, dydxUserFavoriteViewPresenterProtocol {
    @Published var marketId: String?

    private let favoriteStore = dydxFavoriteStore()

    init(handleTap: Bool = true) {
        super.init()

        viewModel = dydxUserFavoriteViewModel()
        viewModel?.handleTap = handleTap
        viewModel?.onTapped = { [weak self] in
            guard let self = self else { return }

            let isFavorited =  !(self.viewModel?.isFavorited ?? false)
            self.viewModel?.isFavorited = isFavorited
            if let marketId = self.marketId {
                self.favoriteStore.setFavorite(isFavorite: isFavorited, marketId: marketId)
            }
        }
    }

    override func start() {
        super.start()

        /* Add observation and update viewModel */
        $marketId
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] marketId in
                guard let self = self, let viewModel = self.viewModel else { return }
                viewModel.isFavorited = self.favoriteStore.isFavorite(marketId: marketId)
            }
            .store(in: &subscriptions)
    }
}
