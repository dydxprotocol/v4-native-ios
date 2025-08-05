//
//  dydxFaucetViewBuilder.swift
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

public class dydxFaucetViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferFaucetViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxTransferOutViewController(presenter: presenter, view: view, configuration: .fullScreenSheet)
        return viewController as? T
    }
}

private class dydxTransferOutViewController: HostingViewController<PlatformView, dydxTransferFaucetViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/faucet" {
            return true
        }
        return false
    }
}

private protocol dydxTransferFaucetViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferFaucetViewModel? { get }
}

private class dydxTransferFaucetViewPresenter: HostedViewPresenter<dydxTransferFaucetViewModel>, dydxTransferFaucetViewPresenterProtocol {

    override init() {
        let viewModel = dydxTransferFaucetViewModel()

        super.init()

        self.viewModel = viewModel

        viewModel.valueSelected = { amount in
            AbacusStateManager.shared.faucet(amount: Int32(amount))
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            ErrorInfo.shared?.info(title: "Faucet Request Submitted",
                                   message: "Your portofolio balance will be updated after a short while.",
                                   type: .success,
                                   error: nil, time: nil)
            HapticFeedback.shared?.notify(type: .success)
        }
    }
}
