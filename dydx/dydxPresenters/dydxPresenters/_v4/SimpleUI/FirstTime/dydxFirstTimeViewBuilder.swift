//
//  dydxFirstTimeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 24/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxFirstTimeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxFirstTimeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxFirstTimeViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

class dydxFirstTimeViewController: HostingViewController<PlatformView, dydxFirstTimeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "<Replace>" {
            return true
        }
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let presenter = presenter as? dydxFirstTimeViewPresenter else {
            return
        }

        presenter.showWelecomeScreen()
    }
}

protocol dydxFirstTimeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxFirstTimeViewModel? { get }
}

class dydxFirstTimeViewPresenter: HostedViewPresenter<dydxFirstTimeViewModel>, dydxFirstTimeViewPresenterProtocol {

    private var started = false

    override init() {
        super.init()

        viewModel = dydxFirstTimeViewModel()
    }

    func showWelecomeScreen() {
        if !started {
            started = true
            let params = ["mode": "welcome"]
            navigate(to: RoutingRequest(path: "/onboard", params: params), animated: true, completion: nil)
        }
    }
}
