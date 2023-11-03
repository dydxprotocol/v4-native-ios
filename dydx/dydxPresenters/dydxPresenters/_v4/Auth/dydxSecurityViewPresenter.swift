//
//  dydxSecurityViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 10/11/23.
//

import LocalAuthentication
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxSecurityViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSecurityViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSecurityViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxSecurityViewController: HostingViewController<PlatformView, dydxSecurityViewModel> {

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if let presenter = presenter as? dydxSecurityViewPresenter, request?.path == "/security" || request?.path == "/security_at_launch" {
            presenter.completionBlock = request?.params?["securityCompleted"] as? (() -> Void)
            return true
        }
        return false
    }
}

private protocol dydxSecurityViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSecurityViewModel? { get }
}

private class dydxSecurityViewPresenter: HostedViewPresenter<dydxSecurityViewModel>, dydxSecurityViewPresenterProtocol {
    fileprivate var completionBlock: (() -> Void)?

    func authenticate() {
        viewModel?.isAuthenticateButtonVisible = false
        viewModel?.errorLabelText = nil

        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .touchID:
            viewModel?.authenticateButtonText = DataLocalizer.localize(path: "APP.GENERAL.AUTHENTICATE_WITH_TOUCH_ID", params: nil)
        case .faceID:
            viewModel?.authenticateButtonText = DataLocalizer.localize(path: "APP.GENERAL.AUTHENTICATE_WITH_FACE_ID", params: nil)
        default:
            viewModel?.authenticateButtonText = DataLocalizer.localize(path: "APP.GENERAL.AUTHENTICATE_WITH_BIOMETRICS", params: nil)
        }

        let prompt = DataLocalizer.localize(path: "APP.GENERAL.AUTHENTICATE_TO_PROCEED", params: nil)
        let policy = LAPolicy.deviceOwnerAuthentication
        context.evaluatePolicy(policy, localizedReason: prompt) { success, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if success {
                    if UIViewController.topmost()?.presentingViewController !== nil {
                        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                            self.completionBlock?()
                        }
                    } else {
                        Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true) { _, _ in
                            self.completionBlock?()
                        }
                    }
                } else {
                    if let errorText = error?.localizedDescription {
                        self.viewModel?.errorLabelText = errorText
                    } else {
                        self.viewModel?.errorLabelText = nil
                    }
                    self.viewModel?.isAuthenticateButtonVisible = true
                }
            }
        }
    }

    override func start() {
        super.start()
        authenticate()
    }

    override init() {
        super.init()

        viewModel = dydxSecurityViewModel()
        viewModel?.authenticateTapped = authenticate
    }
}
