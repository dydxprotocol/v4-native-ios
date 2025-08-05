//
//  dydxTransferOutViewBuilder.swift
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
import FloatingPanel
import PlatformRouting
import dydxFormatter

public class dydxTransferOutViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferOutViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxTransferOutViewController(presenter: presenter, view: view, configuration: .fullScreenSheet)
        return viewController as? T
    }
}

private class dydxTransferOutViewController: HostingViewController<PlatformView, dydxTransferOutViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/transferout" {
            Tracking.shared?.log(event: "NavigateDialog", data: ["type": "Transfer"])
            return true
        }
        return false
    }
}
