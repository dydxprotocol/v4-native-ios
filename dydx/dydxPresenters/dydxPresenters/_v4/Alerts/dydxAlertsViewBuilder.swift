//
//  dydxAlertsViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 9/17/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//
 
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxAlertsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxAlertsViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxAlertsViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxAlertsViewController: HostingViewController<PlatformView, dydxAlertsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/alerts" {
            return true
        }
        return false
    }
}
 
private protocol dydxAlertsViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAlertsViewModel? { get }
}

private class dydxAlertsViewBuilderPresenter: HostedViewPresenter<dydxAlertsViewModel>, dydxAlertsViewBuilderPresenterProtocol {
    private let alertsProvider = dydxAlertsProvider.shared

    override init() {
        super.init()

        viewModel = dydxAlertsViewModel()
        
        viewModel?.listViewModel.contentChanged = { [weak self] in
            self?.viewModel?.objectWillChange.send()
        }
        
        viewModel?.backAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        alertsProvider.items
            .sink { [weak self] viewModels in
                self?.viewModel?.listViewModel.items = viewModels
            }
            .store(in: &subscriptions)
    }
}
