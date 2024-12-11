//
//  dydxOnboardConnectViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/1/23.
//

import Utilities
import dydxStateManager
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxCartera
import dydxAnalytics

public class dydxOnboardConnectViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxOnboardConnectViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxOnboardConnectViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxOnboardConnectViewController: HostingViewController<PlatformView, dydxOnboardConnectViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/connect", let walletId = parser.asString(request?.params?["walletId"]) {
            (presenter as? dydxOnboardConnectViewPresenter)?.walletId = walletId
            return true
        }
        return false
    }
}

private protocol dydxOnboardConnectViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOnboardConnectViewModel? { get }
}

private class dydxOnboardConnectViewPresenter: HostedViewPresenter<dydxOnboardConnectViewModel>, dydxOnboardConnectViewPresenterProtocol {

    var walletId: String?

    private let onboardingAnalytics: OnboardingAnalytics

    private var step1ViewModel: ProgressStepViewModel = {
        let viewModel = ProgressStepViewModel()
        viewModel.title = DataLocalizer.localize(path: "APP.ONBOARDING.CONNECT_YOUR_WALLET")
        viewModel.subtitle = DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET_TEXT")
        viewModel.status = .custom("1")
        return viewModel
    }()

    private var step2ViewModel: ProgressStepViewModel = {
        let viewModel = ProgressStepViewModel()
        viewModel.title = DataLocalizer.localize(path: "APP.ONBOARDING.VERIFY_OWNERSHIP")
        viewModel.subtitle = DataLocalizer.localize(path: "APP.ONBOARDING.CONFIRM_OWNERSHIP")
        viewModel.status = .custom("2")
        return viewModel
    }()

    private let walletSetup: dydxV4WalletSetup

    init(onboardingAnalytics: OnboardingAnalytics = OnboardingAnalytics(), walletSetup: dydxV4WalletSetup = dydxV4WalletSetup()) {
        self.onboardingAnalytics = onboardingAnalytics
        self.walletSetup = walletSetup

        super.init()

        viewModel = dydxOnboardConnectViewModel()
        viewModel?.steps = [step1ViewModel, step2ViewModel]
        viewModel?.ctaAction = { [weak self] in
            if let action = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataAction,
               let domain = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataDomainName {
                self?.walletSetup.start(walletId: self?.walletId,
                                        ethereumChainId: AbacusStateManager.shared.ethereumChainId,
                                        signTypedDataAction: action,
                                        signTypedDataDomainName: domain,
                                        useModal: self?.walletId == nil
                )
            }
        }
    }

    override func start() {
        super.start()

        walletSetup.$status
            .sink { [weak self] status in
                self?.updateStatus(status: status)
            }
            .store(in: &subscriptions)
    }

    private func updateStatus(status: dydxWalletSetup.Status) {
        switch status {
        case .idle:
            step1ViewModel.status = .custom("1")
            step2ViewModel.status = .custom("2")

        case .started:
            step1ViewModel.status = .inProgress
            step2ViewModel.status = .custom("2")

        case .connected:
            step1ViewModel.status = .completed
            step2ViewModel.status = .inProgress

        case .signed(let result):
            step1ViewModel.status = .completed
            step2ViewModel.status = .completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if let cosmoAddress = result.cosmoAddress, let mnemonic = result.mnemonic {
                    self?.onboardingAnalytics.log(step: .keyDerivation)
                    self?.finish(ethereumAddress: result.ethereumAddress, cosmoAddress: cosmoAddress, mnemonic: mnemonic, walletId: result.walletId ?? "")
                }
            }

        case .error(let error):
            step1ViewModel.status = .custom("1")
            step2ViewModel.status = .custom("2")

            let error = error as NSError
            let title = error.userInfo["title"] as? String ?? ""
            let message = error.userInfo["message"] as? String ?? error.localizedDescription
            ErrorInfo.shared?.info(title: title,
                                   message: message,
                                   type: .error,
                                   error: nil, time: nil)
        }
    }

    private func finish(ethereumAddress: String, cosmoAddress: String, mnemonic: String, walletId: String) {
        AbacusStateManager.shared.state.currentWallet
            .prefix(1)
            .sink { walletInstance in
                if walletInstance == nil {
                    let accepted: (() -> Void) = {
                        Router.shared?.navigate(to: RoutingRequest(path: "/portfolio", params: ["ethereumAddress": ethereumAddress, "cosmoAddress": cosmoAddress, "mnemonic": mnemonic, "walletId": walletId]), animated: true, completion: nil)
                    }
                    Router.shared?.navigate(to: RoutingRequest(path: "/onboard/tos", params: ["accepted": accepted]), animated: true, completion: nil)
                } else {
                    Router.shared?.navigate(to: RoutingRequest(path: "/portfolio", params: ["ethereumAddress": ethereumAddress, "cosmoAddress": cosmoAddress, "mnemonic": mnemonic, "walletId": walletId]), animated: true, completion: nil)
                }
            }
            .store(in: &subscriptions)
    }
}
