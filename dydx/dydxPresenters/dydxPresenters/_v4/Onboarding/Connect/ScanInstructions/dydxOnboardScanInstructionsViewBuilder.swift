//
//  dydxOnboardScanInstructionsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/13/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxOnboardScanInstructionsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxOnboardScanInstructionsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxOnboardScanInstructionsViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxOnboardScanInstructionsViewController: HostingViewController<PlatformView, dydxOnboardScanInstructionsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/scan/instructions" {
            return true
        }
        return false
    }
}

private protocol dydxOnboardScanInstructionsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOnboardScanInstructionsViewModel? { get }
}

private class dydxOnboardScanInstructionsViewPresenter: HostedViewPresenter<dydxOnboardScanInstructionsViewModel>, dydxOnboardScanInstructionsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxOnboardScanInstructionsViewModel()

        viewModel?.ctaAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/scan"), animated: true, completion: nil)
        }

        viewModel?.backAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()
    }
}
