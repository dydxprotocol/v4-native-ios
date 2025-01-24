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
import dydxStateManager
import dydxFormatter

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dydxRatingService.shared?.tryPromptForRating()
    }
}

private protocol dydxProfileViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileViewModel? { get }
}

private class dydxProfileViewPresenter: HostedViewPresenter<dydxProfileViewModel>, dydxProfileViewPresenterProtocol {
    private let buttonsPresenter: dydxProfileButtonsViewPresenter
    private let secondaryButtonsPresenter = dydxProfileSecondaryButtonsViewPresenter()
    private let headerPresenter: dydxProfileHeaderViewPresenter
    private let historyPresenter: dydxProfileHistoryViewPresenter
    private let feesPresenter: dydxProfileFeesViewPresenter
    private let rewardsPresenter: dydxProfileRewardsViewPresenter
    private let balancesPresenter: dydxProfileBalancesViewPresenter
    private let topButtonsPresenter = dydxProfileTopButtonsViewPresenter()
    private let helpPresenter = dydxProfileHelpViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        buttonsPresenter,
        secondaryButtonsPresenter,
        headerPresenter,
        historyPresenter,
        feesPresenter,
        rewardsPresenter,
        balancesPresenter,
        topButtonsPresenter,
        helpPresenter
    ]

    override init() {
        let viewModel = dydxProfileViewModel()
        headerPresenter = .init(viewModel: viewModel.header)
        buttonsPresenter = .init(viewModel: viewModel.buttons)
        historyPresenter = .init()
        feesPresenter = .init()
        rewardsPresenter = .init()
        balancesPresenter = .init()

        super.init()

        self.viewModel = viewModel

        historyPresenter.$viewModel.assign(to: &viewModel.$history)
        feesPresenter.$viewModel.assign(to: &viewModel.$fees)
        rewardsPresenter.$viewModel.assign(to: &viewModel.$rewards)
        balancesPresenter.$viewModel.assign(to: &viewModel.$balances)

        if dydxBoolFeatureFlag.simple_ui.isEnabled {
            topButtonsPresenter.$viewModel.assign(to: &viewModel.$topButtons)
            helpPresenter.$viewModel.assign(to: &viewModel.$help)
        } else {
            secondaryButtonsPresenter.$viewModel.assign(to: &viewModel.$secondaryButtons)
        }

        attachChildren(workers: childPresenters)

        viewModel.share?.shareAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/share",
                                                       params: ["text": DataLocalizer.shared?.localize(path: "APP.GENERAL.SHARE_MESSAGE", params: nil) ?? "",
                                                                                       "link": AbacusStateManager.shared.environment?.apps?.ios?.url ?? AbacusStateManager.shared.deploymentUri,
                                                                                       "share_source": "account_screen_share_app_inline_button"]),
                                                       animated: true, completion: nil)
        }
    }
}
