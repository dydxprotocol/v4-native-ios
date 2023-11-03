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
    private let headerPresenter: dydxProfileHeaderViewPresenter
    private let historyPresenter: dydxProfileHistoryViewPresenter
    private let feesPresenter: dydxProfileFeesViewPresenter
    private let rewardsPresenter: dydxProfileRewardsViewPresenter

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        buttonsPresenter,
        headerPresenter,
        historyPresenter,
        feesPresenter,
        rewardsPresenter
    ]

    override init() {
        let viewModel = dydxProfileViewModel()
        headerPresenter = dydxProfileHeaderViewPresenter(viewModel: viewModel.header)
        buttonsPresenter = dydxProfileButtonsViewPresenter(viewModel: viewModel.buttons)
        historyPresenter = dydxProfileHistoryViewPresenter()
        feesPresenter = dydxProfileFeesViewPresenter()
        rewardsPresenter = dydxProfileRewardsViewPresenter()

        super.init()

        self.viewModel = viewModel

        historyPresenter.$viewModel.assign(to: &viewModel.$history)
        feesPresenter.$viewModel.assign(to: &viewModel.$fees)
        rewardsPresenter.$viewModel.assign(to: &viewModel.$rewards)

        attachChildren(workers: childPresenters)
    }
}
