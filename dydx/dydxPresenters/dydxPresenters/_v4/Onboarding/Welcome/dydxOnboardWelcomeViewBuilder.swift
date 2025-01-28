//
//  dydxOnboardWelcomeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/22/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxAnalytics
import PanModal

public class dydxOnboardWelcomeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxOnboardWelcomeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxOnboardWelcomeViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxOnboardWelcomeViewController: HostingViewController<PlatformView, dydxOnboardWelcomeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard" {
            if let mode = request?.params?["mode"] as? String,
            let presenter = presenter as? dydxOnboardWelcomeViewPresenter {
                if mode == "welcome" {
                    presenter.mode = .simpleUIWelcome
                }
            }
            return true
        } else {
            return false
        }
    }
}

private protocol dydxOnboardWelcomeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOnboardWelcomeViewModel? { get }
}

private class dydxOnboardWelcomeViewPresenter: HostedViewPresenter<dydxOnboardWelcomeViewModel>, dydxOnboardWelcomeViewPresenterProtocol {
    enum Mode {
        case simpleUIWelcome
        case walletOnboard
    }

    var mode: Mode = .walletOnboard

    private let onboardingAnalytics: OnboardingAnalytics

    init(onboardingAnalytics: OnboardingAnalytics = OnboardingAnalytics()) {
        self.onboardingAnalytics = OnboardingAnalytics()
        super.init()

        viewModel = dydxOnboardWelcomeViewModel()
        viewModel?.ctaAction = { [weak self] in
            guard let self else { return }
            switch self.mode {
            case .simpleUIWelcome:
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                    Router.shared?.navigate(to: RoutingRequest(path: "/settings/app_mode"), animated: true, completion: nil)
                }
            case .walletOnboard:
                self.onboardingAnalytics.log(step: .chooseWallet)
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
            }
        }
        viewModel?.tosUrl = AbacusStateManager.shared.environment?.links?.tos
        viewModel?.privacyPolicyUrl = AbacusStateManager.shared.environment?.links?.privacy
    }

    override func onHalfSheetDismissal() {
        super.onHalfSheetDismissal()

        switch mode {
        case .simpleUIWelcome:
            Router.shared?.navigate(to: RoutingRequest(path: "/settings/app_mode"), animated: true, completion: nil)
        case .walletOnboard:
            // no-op
            break
        }
    }
}
