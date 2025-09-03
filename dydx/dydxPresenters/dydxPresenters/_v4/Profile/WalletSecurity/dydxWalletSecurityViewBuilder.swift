//
//  dydxWalletSecurityViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 04/08/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Combine

public class dydxWalletSecurityViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxWalletSecurityViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxWalletSecurityViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxWalletSecurityViewController: HostingViewController<PlatformView, dydxWalletSecurityViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/profile/security" {
            return true
        }
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let presenter = presenter as? dydxWalletSecurityViewPresenter {
            presenter.isPushed = isPushed
        }
    }

    private var isPushed: Bool {
        navigationController?.viewControllers.firstIndex(of: self) ?? 0 > 0
    }
}

private protocol dydxWalletSecurityViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxWalletSecurityViewModel? { get }
}

private class dydxWalletSecurityViewPresenter: HostedViewPresenter<dydxWalletSecurityViewModel>, dydxWalletSecurityViewPresenterProtocol {
    var isPushed: Bool = true {
        didSet {
            viewModel?.showBackbutton = isPushed
        }
    }

    override init() {
        super.init()

        viewModel = dydxWalletSecurityViewModel()
        viewModel?.cancelAction = { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.loginAction = { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/onboard/turnkey"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] wallet in
                guard let wallet = wallet else {
                    return
                }
                self?.updateViewModel(wallet: wallet)
            }
            .store(in: &subscriptions)
    }

    private func updateViewModel(wallet: dydxWalletInstance) {
        let loginMethod: dydxWalletSecurityViewModel.LoginMethod?
        if let login = wallet.loginMethod {
            loginMethod = dydxWalletSecurityViewModel.LoginMethod(rawValue: login) ?? .email
        } else {
            loginMethod = nil
        }
        if let loginMethod {
            viewModel?.loginMethod = loginMethod
        }
        if loginMethod == .apple {
            viewModel?.email = "Apple User"
        } else {
            viewModel?.email = wallet.userEmail
        }
        viewModel?.sourceAddress = wallet.ethereumAddress
        viewModel?.dydxAddress = wallet.cosmoAddress
        viewModel?.exportSourceAction = { [weak self] in
            guard let mnemonic = wallet.mnemonic else {
                return
            }
            let params = ["mnemonic": mnemonic]
            self?.navigate(to: RoutingRequest(path: "/my-profile/keyexport", params: params as [String: Any]), animated: true, completion: nil)
        }

        viewModel?.exportDydxAction = { [weak self] in
            guard let mnemonic = wallet.sourceWalletMnemonic else {
                return
            }
            let params = ["mnemonic": mnemonic]
            self?.navigate(to: RoutingRequest(path: "/my-profile/keyexport", params: params as [String: Any]), animated: true, completion: nil)
        }
    }
}
