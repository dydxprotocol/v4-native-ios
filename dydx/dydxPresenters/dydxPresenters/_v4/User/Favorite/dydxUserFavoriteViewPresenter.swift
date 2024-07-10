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
}
