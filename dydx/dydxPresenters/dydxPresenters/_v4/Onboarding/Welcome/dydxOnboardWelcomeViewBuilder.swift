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
    private let onboardingAnalytics: OnboardingAnalytics

    init(onboardingAnalytics: OnboardingAnalytics = OnboardingAnalytics()) {
        self.onboardingAnalytics = OnboardingAnalytics()
        super.init()

        viewModel = dydxOnboardWelcomeViewModel()
        viewModel?.ctaAction = { [weak self] in
            self?.onboardingAnalytics.log(step: .chooseWallet)
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
        }
        viewModel?.tosUrl = AbacusStateManager.shared.environment?.links?.tos
        viewModel?.privacyPolicyUrl = AbacusStateManager.shared.environment?.links?.privacy
    }
}
