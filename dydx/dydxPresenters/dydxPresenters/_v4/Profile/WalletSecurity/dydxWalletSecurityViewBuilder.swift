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

public class dydxWalletSecurityViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxWalletSecurityViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxWalletSecurityViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxWalletSecurityViewController: HostingViewController<PlatformView, dydxWalletSecurityViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/profile/security" {
            return true
        }
        return false
    }
}

private protocol dydxWalletSecurityViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxWalletSecurityViewModel? { get }
}

private class dydxWalletSecurityViewPresenter: HostedViewPresenter<dydxWalletSecurityViewModel>, dydxWalletSecurityViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxWalletSecurityViewModel()
    }
}
