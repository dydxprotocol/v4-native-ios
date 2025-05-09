//
//  dydxSimpleUIMarketsHeaderViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 05/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import dydxFormatter

protocol dydxSimpleUIMarketsHeaderViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketsHeaderViewModel? { get }
}

class dydxSimpleUIMarketsHeaderViewPresenter: HostedViewPresenter<dydxSimpleUIMarketsHeaderViewModel>, dydxSimpleUIMarketsHeaderViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketsHeaderViewModel()
        viewModel?.menuAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/simple_ui/menu", params: nil), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            AbacusStateManager.shared.state.walletState
        )
        .sink { [weak self] onboarded, walletState in
            guard let self = self else { return }
            self.update(onboarded: onboarded, currentWallet: walletState.currentWallet)
        }
        .store(in: &subscriptions)
    }

    private func update(onboarded: Bool, currentWallet: dydxWalletInstance?) {
        viewModel?.onboarded = onboarded

        if onboarded {
//            viewModel?.depositAction = { [weak self] in
//                self?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.deposit.rawValue]), animated: true, completion: nil)
//            }
//            viewModel?.withdrawAction = {
//                Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.withdrawal.rawValue]), animated: true, completion: nil)
//            }
        } else {
            viewModel?.depositAction = nil
            viewModel?.withdrawAction = nil
        }
    }
}
