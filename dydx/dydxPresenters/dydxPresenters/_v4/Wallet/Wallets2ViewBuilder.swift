//
//  Wallets2VewPresenter.swift
//  dydxViews
//
//  Created by Rui Huang on 8/29/22.
//

import Foundation
import ParticlesKit
import dydxViews
import dydxFormatter
import PlatformUI
import RoutingKit
import dydxStateManager
import Utilities
import Combine
import Cartera

public class Wallets2ViewBuilder: NSObject, ObjectBuilderProtocol {
    private enum WalletStatePublisherError: Error {
       case timeout
    }

    private var walletStateSubscribers = [AnyCancellable]()

    public func build<T>() -> T? {
        nil
    }

    public func buildAsync<T>(completion: @escaping ((T?) -> Void)) {
        let presenter = Wallets2ViewPresenter()
        let view = presenter.viewModel?.createView() ?? Wallets2ViewModel().createView()
        let viewController = WalletV2ViewController(presenter: presenter, view: view, configuration: .init(ignoreSafeArea: true))

        // Wait for the wallet list before completion, so that the list is ready before the view is presentered.
        // This is because the PanModal presenter needs intrinsicContentSize of the view to determine
        // the bottom sheet height.

        presenter.start()
        presenter.$walletStateLoaded
            .filter { $0 }
            .prefix(1)
            .setFailureType(to: WalletStatePublisherError.self)
            .timeout(.seconds(1), scheduler: DispatchQueue.main, customError: { .timeout })
            .sink(receiveCompletion: { _ in
                completion(viewController as? T)
                presenter.stop()
            }, receiveValue: { _ in  })
            .store(in: &walletStateSubscribers)
    }
}

private class WalletV2ViewController: HostingViewController<PlatformView, Wallets2ViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/wallets" {
            return true
        }
        return false
    }
}

private class Wallets2ViewPresenter: HostedViewPresenter<Wallets2ViewModel> {
    private var walletStateSubscribers = [AnyCancellable]()

    @Published var walletStateLoaded: Bool = false

    override init() {
        super.init()

        viewModel = Wallets2ViewModel()
        viewModel?.buttonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.walletState
            .sink { [weak self] walletState in
                self?.updateWalletState(walletState: walletState)
                self?.walletStateLoaded = true
            }
            .store(in: &walletStateSubscribers)
    }

    private func updateWalletState(walletState: dydxWalletState) {
        viewModel?.walletConnections = walletState.wallets.map { wallet in
            let viewModel = WalletConnectionViewModel()
            viewModel.walletAddress = wallet.ethereumAddress
            viewModel.selected = wallet == walletState.currentWallet
            viewModel.onTap = {
                if let cosmoAddress = wallet.cosmoAddress, let mnemonic = wallet.mnemonic {
                    AbacusStateManager.shared.setV4(ethereumAddress: wallet.ethereumAddress,
                                                    walletId: wallet.walletId,
                                                    cosmoAddress: cosmoAddress,
                                                    mnemonic: mnemonic)
                }
            }

            viewModel.walletImageUrl  = wallet.imageUrl

            // TODO:
//            viewModel.equity =
//            viewModel.pnl24hPercent =

            return viewModel
        }
    }
}
