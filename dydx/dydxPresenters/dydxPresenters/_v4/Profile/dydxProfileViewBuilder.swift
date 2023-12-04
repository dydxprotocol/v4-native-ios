//
//  dydxProfileViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 2/7/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxProfileViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxProfileViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxProfileViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxProfileViewController: HostingViewController<PlatformView, dydxProfileViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/my-profile" {
            return true
        }
        return false
    }
}

private protocol dydxProfileViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileViewModel? { get }
}

private class dydxProfileViewPresenter: HostedViewPresenter<dydxProfileViewModel>, dydxProfileViewPresenterProtocol {
    private let buttonsPresenter: dydxProfileButtonsViewPresenter
    private let settingsHelpRowPresenter: dydxSettingsHelpRowViewPresenter
    private let headerPresenter: dydxProfileHeaderViewPresenter
    private let historyPresenter: dydxProfileHistoryViewPresenter
    private let feesPresenter: dydxProfileFeesViewPresenter
    private let balancessPresenter: dydxProfileBalancesViewPresenter

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        buttonsPresenter,
        settingsHelpRowPresenter,
        headerPresenter,
        historyPresenter,
        feesPresenter,
        balancessPresenter
    ]

    override init() {
        let viewModel = dydxProfileViewModel()
        headerPresenter = .init(viewModel: viewModel.header)
        settingsHelpRowPresenter = .init(viewModel: viewModel.settingsHelp)
        buttonsPresenter = .init(viewModel: viewModel.buttons)
        historyPresenter = .init()
        feesPresenter = .init()
        balancessPresenter = .init()

        super.init()

        self.viewModel = viewModel

        historyPresenter.$viewModel.assign(to: &viewModel.$history)
        feesPresenter.$viewModel.assign(to: &viewModel.$fees)
        balancessPresenter.$viewModel.assign(to: &viewModel.$balances)

        attachChildren(workers: childPresenters)
    }
}
