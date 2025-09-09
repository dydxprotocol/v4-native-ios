//
//  dydxSimpleUIMenuButtonsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 21/04/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter
import Combine

protocol dydxSimpleUIMenuButtonsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMenuButtonsViewModel? { get }
}

class dydxSimpleUIMenuButtonsViewPresenter: HostedViewPresenter<dydxSimpleUIMenuButtonsViewModel>, dydxSimpleUIMenuButtonsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMenuButtonsViewModel()
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.currentWallet,
            AbacusStateManager.shared.state.selectedSubaccount
                .map(\.?.freeCollateral?.current)
                .removeDuplicates()
        )
        .sink { [weak self] wallet, freeCollateral in
            self?.updateViewModel(wallet: wallet, freeCollateral: freeCollateral?.doubleValue)
        }
        .store(in: &subscriptions)
    }

    private func updateViewModel(wallet: dydxWalletInstance?, freeCollateral: Double?) {
        if wallet != nil {
            viewModel?.depositAction = { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/transfer/deposit", params: nil), animated: true, completion: nil)
            }
        }
        if freeCollateral ?? 0 > 0 {
            viewModel?.transferAction = { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/transfer/selector", params: nil), animated: true, completion: nil)
            }
        }
    }

}
