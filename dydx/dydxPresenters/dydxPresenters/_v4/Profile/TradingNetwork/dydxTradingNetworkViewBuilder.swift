//
//  dydxTradingNetworkViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/14/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus

public class dydxTradingNetworkViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTradingNetworkViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTradingNetworkViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTradingNetworkViewController: HostingViewController<PlatformView, dydxTradingNetworkViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/settings/env" {
            return true
        }
        return false
    }
}

private protocol dydxTradingNetworkViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradingNetworkViewModel? { get }
}

private class dydxTradingNetworkViewPresenter: HostedViewPresenter<dydxTradingNetworkViewModel>, dydxTradingNetworkViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradingNetworkViewModel()

        viewModel?.items = AbacusStateManager.shared.availableEnvironments.map { (selection: SelectionOption) -> dydxTradingNetworkItemViewModel in
            let item = dydxTradingNetworkItemViewModel()
            item.text = selection.localizedString
            item.selected = AbacusStateManager.shared.currentEnvironment == selection.type
            item.onSelected = {
                AbacusStateManager.shared.currentEnvironment = selection.type
                Router.shared?.navigate(to: RoutingRequest(path: "/loading"), animated: true, completion: { _, _ in
                    Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true, completion: { _, _ in
                    })
                })
            }
            return item
        }
    }

    override func start() {
        super.start()

    }
}
