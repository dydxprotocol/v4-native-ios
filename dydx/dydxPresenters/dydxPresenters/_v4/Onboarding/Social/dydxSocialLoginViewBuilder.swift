//
//  dydxSocialLoginViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 01/05/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxCartera

public class dydxSocialLoginViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSocialLoginViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSocialLoginViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxSocialLoginViewController: HostingViewController<PlatformView, dydxSocialLoginViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/social" {
            return true
        }
        return false
    }
}

private protocol dydxSocialLoginViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSocialLoginViewModel? { get }
}

private class dydxSocialLoginViewPresenter: HostedViewPresenter<dydxSocialLoginViewModel>, dydxSocialLoginViewPresenterProtocol {

    private let connectWalletViewModel: dydxConnectWalletViewModel = {
        let viewModel = dydxConnectWalletViewModel()
        viewModel.onTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) {_, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets", params: nil), animated: true, completion: nil)
            }
        }
        return viewModel
    }()

    override init() {
        super.init()

        viewModel = dydxSocialLoginViewModel()
        viewModel?.connectWallet = connectWalletViewModel
        viewModel?.googleAction = {
            Task {
                let ret = await PrivyAuthManager.shared?.loginOAuth(type: .google)
                if let error = ret?.error {
                    DispatchQueue.main.async {
                        ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"), message: nil, error: error)
                    }
                }
            }
        }
    }
}
