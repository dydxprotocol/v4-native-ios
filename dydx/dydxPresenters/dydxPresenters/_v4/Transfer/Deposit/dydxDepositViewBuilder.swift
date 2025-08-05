//
//  dydxDepositViewBuilder.swift
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

public class dydxDepositViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        if dydxBoolFeatureFlag.turnkey_ios.isEnabled {
            let presenter = dydxTurnkeyDepositViewPresenter()
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            let viewController = dydxTurnkeyDepositViewController(presenter: presenter, view: view, configuration: .fullScreenSheet)
            return viewController as? T
        } else {
            let presenter = dydxInstantDepositViewPresenter()
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            let viewController = dydxInstantDepositViewController(presenter: presenter, view: view, configuration: .fullScreenSheet)
            return viewController as? T
        }
    }
}

private class dydxInstantDepositViewController: HostingViewController<PlatformView, dydxInstantDepositViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit" {
            Tracking.shared?.log(event: "NavigateDialog", data: ["type": "Deposit2"])
            return true
        }
        return false
    }
}

private class dydxTurnkeyDepositViewController: HostingViewController<PlatformView, dydxTurnkeyDepositViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit" {
            Tracking.shared?.log(event: "NavigateDialog", data: ["type": "Deposit2"])
            return true
        }
        return false
    }
}
