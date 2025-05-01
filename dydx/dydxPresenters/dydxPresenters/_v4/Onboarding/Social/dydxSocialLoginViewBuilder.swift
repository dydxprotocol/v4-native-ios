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

public class dydxSocialLoginViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSocialLoginViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSocialLoginViewController(presenter: presenter, view: view, configuration: .default) as? T
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
    override init() {
        super.init()

        viewModel = dydxSocialLoginViewModel()
        
        viewModel?.headerView.title = DataLocalizer.localize(path: "APP.GENERAL.FEES")
        viewModel?.headerView.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

    }
}
