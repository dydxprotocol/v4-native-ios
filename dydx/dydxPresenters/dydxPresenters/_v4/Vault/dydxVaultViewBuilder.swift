//
//  dydxVaultViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 7/30/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//
// Move the builder code to the dydxPresenters module for v4, or dydxUI modules for v3

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxVaultViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxVaultViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxVaultViewController(presenter: presenter, view: view, configuration: .default) as? T
        // return HostingViewController(presenter: presenter, view: view) as? T
    }
}

private class dydxVaultViewController: HostingViewController<PlatformView, dydxVaultViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/vault" {
            return true
        }
        return false
    }
}

private protocol dydxVaultViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultViewModel? { get }
}

private class dydxVaultViewBuilderPresenter: HostedViewPresenter<dydxVaultViewModel>, dydxVaultViewBuilderPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxVaultViewModel()
    }
}
