//
//  dydxTosViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 8/29/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager

public class dydxTosViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTosViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTosViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxTosViewController: HostingViewController<PlatformView, dydxTosViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/tos", let presenter = presenter as? dydxTosViewPresenterProtocol {
            if let accepted = request?.params?["accepted"] as? (() -> Void) {
                presenter.accepted = accepted
            }
            return true
        }
        return false
    }
}

private protocol dydxTosViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTosViewModel? { get }
    var accepted: (() -> Void)? { get set }
}

private class dydxTosViewPresenter: HostedViewPresenter<dydxTosViewModel>, dydxTosViewPresenterProtocol {
    private let onboardingAnalytics: OnboardingAnalytics

    var accepted: (() -> Void)? {
        didSet {
            viewModel?.ctaAction = { [weak self] in
                self?.onboardingAnalytics.log(step: .acknowledgeTerms)
                self?.accepted?()
            }
        }
    }

    init(onboardingAnalytics: OnboardingAnalytics = OnboardingAnalytics()) {
        self.onboardingAnalytics = onboardingAnalytics

        super.init()

        viewModel = dydxTosViewModel()
        viewModel?.tosUrl = AbacusStateManager.shared.environment?.links?.tos
        viewModel?.privacyPolicyUrl = AbacusStateManager.shared.environment?.links?.privacy
    }
}
