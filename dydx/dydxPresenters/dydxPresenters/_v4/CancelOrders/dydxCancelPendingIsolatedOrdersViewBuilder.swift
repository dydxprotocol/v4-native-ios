//
//  dydxCancelPendingIsolatedOrdersViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 6/17/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxCancelPendingIsolatedOrdersViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxCancelPendingIsolatedOrdersViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxCancelPendingIsolatedOrdersViewBuilderController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxCancelPendingIsolatedOrdersViewBuilderController: HostingViewController<PlatformView, dydxCancelPendingIsolatedOrdersViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/portfolio/cancel_pending_position" {
            return true
        }
        return false
    }
}

private protocol dydxCancelPendingIsolatedOrdersViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxCancelPendingIsolatedOrdersViewModel? { get }
}

private class dydxCancelPendingIsolatedOrdersViewBuilderPresenter: HostedViewPresenter<dydxCancelPendingIsolatedOrdersViewModel>, dydxCancelPendingIsolatedOrdersViewBuilderPresenterProtocol {
    override init() {
        super.init()

        self.viewModel = .previewValue
    }
}
