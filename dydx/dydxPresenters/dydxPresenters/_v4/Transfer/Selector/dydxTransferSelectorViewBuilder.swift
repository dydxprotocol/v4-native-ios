//
//  dydxTransferSelectorViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 05/08/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager

public class dydxTransferSelectorViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferSelectorViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTransferSelectorViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxTransferSelectorViewController: HostingViewController<PlatformView, dydxTransferSelectorViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/selector" {
            return true
        }
        return false
    }
}

private protocol dydxTransferSelectorViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferSelectorViewModel? { get }
}

private class dydxTransferSelectorViewPresenter: HostedViewPresenter<dydxTransferSelectorViewModel>, dydxTransferSelectorViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTransferSelectorViewModel()
        viewModel?.isMainnet = AbacusStateManager.shared.isMainNet
        viewModel?.onAction = { action in
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                switch action {
                case .deposit:
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit"), animated: true, completion: nil)
                case .withdrawal:
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer/withdrawal"), animated: true, completion: nil)
                case .transferOut:
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer/transferout"), animated: true, completion: nil)
                case .faucet:
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer/faucet"), animated: true, completion: nil)
                }
            }

        }
    }
}
