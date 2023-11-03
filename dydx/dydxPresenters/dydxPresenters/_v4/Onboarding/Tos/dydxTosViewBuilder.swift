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
        return dydxTosViewController(presenter: presenter, view: view, configuration: .init(ignoreSafeArea: true)) as? T
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
    var accepted: (() -> Void)? {
        didSet {
            viewModel?.ctaAction = { [weak self] in
                self?.accepted?()
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxTosViewModel()
        viewModel?.ctaAction = { [weak self] in
            self?.accepted?()
        }
        viewModel?.tosUrl = AbacusStateManager.shared.environment?.links?.tos
        viewModel?.privacyPolicyUrl = AbacusStateManager.shared.environment?.links?.privacy
    }

    override func start() {
        super.start()

        /* Add observation and update viewModel */
    }
}
