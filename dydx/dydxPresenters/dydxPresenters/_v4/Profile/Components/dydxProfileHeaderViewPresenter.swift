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
import Utilities

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
        self.viewModel?.manageWalletAction = { [weak self] in
            guard let self = self else {
                return
            }
            AbacusStateManager.shared.state.walletState
                .prefix(1)
                .sink { walletState in
                    if walletState.wallets.count > 0 {
                        Router.shared?.navigate(to: RoutingRequest(path: "/wallets"), animated: true, completion: nil)
                    } else {
                        Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
                    }
                }
                .store(in: &self.subscriptions)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.walletState
            .sink { [weak self] walletState in
                self?.viewModel?.dydxAddress = walletState.currentWallet?.cosmoAddress
                self?.viewModel?.sourceAddress = walletState.currentWallet?.ethereumAddress
                if let cosmoAddress = walletState.currentWallet?.cosmoAddress {
                    self?.viewModel?.copyAction = {
                        UIPasteboard.general.string = cosmoAddress
                    }
                } else {
                    self?.viewModel?.copyAction = nil
                }
                if let cosmoAddress = walletState.currentWallet?.cosmoAddress,
                    let mintscanBase = AbacusStateManager.shared.environment?.links?.mintscanBase {
                    self?.viewModel?.openInEtherscanAction = {
                        let urlString = "\(mintscanBase)/address/\(cosmoAddress)"
                        if let url = URL(string: urlString), URLHandler.shared?.canOpenURL(url) ?? false {
                            URLHandler.shared?.open(url, completionHandler: nil)
                        }
                    }
                } else {
                    self?.viewModel?.openInEtherscanAction = nil
                }
            }
            .store(in: &subscriptions)
    }
}
