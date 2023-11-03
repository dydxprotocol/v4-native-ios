//
//  dydxFeesStuctureViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/2/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxFeesStuctureViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxFeesStuctureViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxFeesStuctureViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxFeesStuctureViewController: HostingViewController<PlatformView, dydxFeesStuctureViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/profile/fees" {
            return true
        }
        return false
    }
}

private protocol dydxFeesStuctureViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxFeesStuctureViewModel? { get }
}

private class dydxFeesStuctureViewPresenter: HostedViewPresenter<dydxFeesStuctureViewModel>, dydxFeesStuctureViewPresenterProtocol {
    private let feesPresenter: dydxPortfolioFeesViewPresenter

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        feesPresenter
    ]

    override init() {
        let viewModel = dydxFeesStuctureViewModel()
        viewModel.headerViewModel?.title = DataLocalizer.localize(path: "APP.GENERAL.FEES")
        viewModel.headerViewModel?.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        feesPresenter = dydxPortfolioFeesViewPresenter(viewModel: viewModel.feesViewModel)

        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        attachChildren(workers: childPresenters)
    }
}
