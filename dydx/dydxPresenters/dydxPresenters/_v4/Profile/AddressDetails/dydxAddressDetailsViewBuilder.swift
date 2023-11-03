//
//  dydxAddressDetailsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/5/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Cartera

public class dydxAddressDetailsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxAddressDetailsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxAddressDetailsViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxAddressDetailsViewController: HostingViewController<PlatformView, dydxAddressDetailsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/my-profile/address" {
            return true
        }
        return false
    }
}

private protocol dydxAddressDetailsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAddressDetailsViewModel? { get }
}

private class dydxAddressDetailsViewPresenter: HostedViewPresenter<dydxAddressDetailsViewModel>, dydxAddressDetailsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxAddressDetailsViewModel()
        if let chainLogo = AbacusStateManager.shared.environment?.chainLogo {
            viewModel?.dydxChainLogoUrl = URL(string: chainLogo)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.walletState
            .sink { [weak self] walletState in
                self?.viewModel?.dydxAddress = walletState.currentWallet?.cosmoAddress
                self?.viewModel?.sourceAddress = walletState.currentWallet?.ethereumAddress

                self?.viewModel?.sourceWalletImageUrl = walletState.currentWallet?.imageUrl

                self?.viewModel?.copyAddressAction = {
                    guard let cosmoAddress = walletState.currentWallet?.cosmoAddress else {
                        return
                    }
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = cosmoAddress

                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS_COPIED"),
                                           type: .success,
                                           error: nil, time: 3)
                }

                self?.viewModel?.etherscanAction = {
                    guard let ethereumAddress = walletState.currentWallet?.ethereumAddress else {
                        return
                    }

                    let urlString = "https://etherscan.io/address/\(ethereumAddress)"
                    if let url = URL(string: urlString), URLHandler.shared?.canOpenURL(url) ?? false {
                        URLHandler.shared?.open(url, completionHandler: nil)
                    }
                }

                self?.viewModel?.keyExportAction = {
                    Router.shared?.navigate(to: RoutingRequest(url: "/my-profile/keyexport"), animated: true, completion: nil)
                }
            }
            .store(in: &subscriptions)
    }
}
