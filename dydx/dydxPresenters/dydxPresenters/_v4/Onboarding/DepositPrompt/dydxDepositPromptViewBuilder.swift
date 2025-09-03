//
//  DydxDepositPromptViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 28/08/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Combine

public class dydxDepositPromptViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxDepositPromptViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxDepositPromptViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxDepositPromptViewController: HostingViewController<PlatformView, dydxDepositPromptViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/deposit_prompt" {
            return true
        }
        return false
    }
}

private protocol dydxDepositPromptViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxDepositPromptViewModel? { get }
}

private class dydxDepositPromptViewPresenter: HostedViewPresenter<dydxDepositPromptViewModel>, dydxDepositPromptViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxDepositPromptViewModel()
        viewModel?.onCtaAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit"), animated: true, completion: nil)
            }
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] wallet in
                let loginMode: dydxDepositPromptViewModel.LoginMode?
                if let loginMethod = wallet?.loginMethod?.lowercased() {
                    loginMode = dydxDepositPromptViewModel.LoginMode(rawValue: loginMethod)
                } else {
                    loginMode = nil
                }
                self?.viewModel?.mode = loginMode

                if loginMode == .apple {
                    self?.viewModel?.user = "Apple User"
                } else {
                    self?.viewModel?.user = wallet?.userEmail
                }
            }
            .store(in: &subscriptions)
    }
}
