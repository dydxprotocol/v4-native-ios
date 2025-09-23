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
        let presenter = dydxDepositViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxDepositViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxDepositViewController: HostingViewController<PlatformView, dydxDepositViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit" {
            Tracking.shared?.log(event: "NavigateDialog", data: ["type": "Deposit2"])
            return true
        }
        return false
    }
}

private protocol dydxDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxDepositViewModel? { get }
}

private class dydxDepositViewPresenter: HostedViewPresenter<dydxDepositViewModel>, dydxDepositViewPresenterProtocol {
    private let instantPresenter = dydxInstantDepositViewPresenter()
    private let turnkeyPresenter = dydxTurnkeyDepositViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        instantPresenter,
        turnkeyPresenter
    ]

    override init() {
        let viewModel = dydxDepositViewModel()

        instantPresenter.$viewModel.assign(to: &viewModel.$instant)
        turnkeyPresenter.$viewModel.assign(to: &viewModel.$turnkey)

        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.walletState
            .sink { [weak self]  walletState in
                guard let self else { return }
                if walletState.currentWallet?.walletId == "turnkey" {
                    self.viewModel?.mode = .turnkey
                    self.attachChild(worker: self.turnkeyPresenter)
                } else {
                    self.viewModel?.mode = .instant
                    self.attachChild(worker: self.instantPresenter)
                }
            }
            .store(in: &subscriptions)

        attachChildren(workers: childPresenters)
    }
}
