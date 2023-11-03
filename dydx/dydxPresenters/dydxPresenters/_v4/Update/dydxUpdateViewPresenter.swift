//
//  dydxUpdateViewPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 10/24/23.
//

import Abacus
import dydxStateManager
import dydxViews
import LocalAuthentication
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities

public class dydxUpdateViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxUpdateViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxUpdateViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxUpdateViewController: HostingViewController<PlatformView, dydxUpdateViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/update" {
            return true
        }
        return false
    }
}

private protocol dydxUpdateViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxUpdateViewModel? { get }
}

private class dydxUpdateViewPresenter: HostedViewPresenter<dydxUpdateViewModel>, dydxUpdateViewPresenterProtocol {
    override func start() {
        super.start()

        if let ios = AbacusStateManager.shared.environment?.apps?.ios {
            viewModel?.title = ios.title
            viewModel?.text = ios.text
            viewModel?.action = ios.action
            viewModel?.updateTapped = { [weak self] in
                if let url = URL(string: ios.url) {
                    Router.shared?.navigate(to: url, completion: nil)
                }
            }
        }
    }

    override init() {
        super.init()

        viewModel = dydxUpdateViewModel()
    }
}
