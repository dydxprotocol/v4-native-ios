//
//  dydxWithdrawalViewBuilder.swift
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

public class dydxWithdrawalViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferWithdrawalViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxWithdrawalViewController(presenter: presenter, view: view, configuration: .fullScreenSheet)
        return viewController as? T
    }
}

private class dydxWithdrawalViewController: HostingViewController<PlatformView, dydxTransferWithdrawalViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/withdrawal" {
            Tracking.shared?.log(event: "NavigateDialog", data: ["type": "Withdraw2"])
            return true
        }
        return false
    }
}
