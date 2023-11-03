//
//  dydxProfileHeaderViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/5/23.
//

import Foundation
import Abacus
import dydxStateManager
import dydxViews
import RoutingKit

protocol dydxProfileHeaderViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileHeaderViewModel? { get }
}

class dydxProfileHeaderViewPresenter: HostedViewPresenter<dydxProfileHeaderViewModel>, dydxProfileHeaderViewPresenterProtocol {

    init(viewModel: dydxProfileHeaderViewModel) {
        super.init()
        self.viewModel = viewModel
        if let chainLogo = AbacusStateManager.shared.environment?.chainLogo {
            self.viewModel?.dydxChainLogoUrl = URL(string: chainLogo)
        }
        self.viewModel?.onTapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/my-profile/address"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.walletState
            .sink { [weak self] walletState in
                self?.viewModel?.dydxAddress = walletState.currentWallet?.cosmoAddress
            }
            .store(in: &subscriptions)
    }
}
