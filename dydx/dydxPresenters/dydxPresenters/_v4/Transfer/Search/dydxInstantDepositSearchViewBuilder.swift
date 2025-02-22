//
//  dydxInstantDepositSearchViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 21/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxInstantDepositSearchViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxInstantDepositSearchViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxInstantDepositSearchViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxInstantDepositSearchViewController: HostingViewController<PlatformView, dydxInstantDepositSearchViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit/search" {
            return true
        }
        return false
    }
}

private protocol dydxInstantDepositSearchViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxInstantDepositSearchViewModel? { get }
}

private class dydxInstantDepositSearchViewPresenter: HostedViewPresenter<dydxInstantDepositSearchViewModel>, dydxInstantDepositSearchViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxInstantDepositSearchViewModel()
        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.tokens = [.previewValue]
    }
}
