//
//  dydxFiatDepositViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 29/09/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxFiatDepositViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxFiatDepositViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxFiatDepositViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxFiatDepositViewController: HostingViewController<PlatformView, dydxFiatDepositViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit/fiat" {
            return true
        }
        return false
    }
}

private protocol dydxFiatDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxFiatDepositViewModel? { get }
}

private class dydxFiatDepositViewPresenter: HostedViewPresenter<dydxFiatDepositViewModel>, dydxFiatDepositViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxFiatDepositViewModel()

        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        viewModel?.providerName = "MoonPay"
        viewModel?.providerIcon = "logo_moonpay"
        viewModel?.providerSubtitle = DataLocalizer.localize(path: "APP.DEPOSIT_WITH_FIAT.MOONPAY_SUPPORT")
    }
}
