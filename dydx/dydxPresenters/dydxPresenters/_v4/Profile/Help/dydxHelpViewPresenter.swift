//
//  dydxHelpViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/24/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager

public class dydxHelpViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxHelpViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxHelpViewController(presenter: presenter, view: view, configuration: .ignoreSafeArea) as? T
    }
}

private class dydxHelpViewController: HostingViewController<PlatformView, dydxHelpViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/help" {
            return true
        }
        return false
    }
}

private protocol dydxHelpViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxHelpViewModel? { get }
}

private class dydxHelpViewPresenter: HostedViewPresenter<dydxHelpViewModel>, dydxHelpViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxHelpViewModel()

        var items: [dydxHelpViewModel.Item] = []

        if let help = AbacusStateManager.shared.environment?.links?.help {
            items.append(dydxHelpViewModel.Item(icon: "help_chatbot",
                                                title: DataLocalizer.localize(path: "APP.HELP_MODAL.LIVE_CHAT"),
                                                subtitle: DataLocalizer.localize(path: "APP.HELP_MODAL.LIVE_CHAT_DESCRIPTION"),
                                                onTapAction: { [weak self] in
                                                    self?.handleLink(link: help)
                                                }))
        }

        if let community = AbacusStateManager.shared.environment?.links?.community {
            items.append(dydxHelpViewModel.Item(icon: "help_discord",
                                                title: DataLocalizer.localize(path: "APP.HELP_MODAL.JOIN_DISCORD"),
                                                subtitle: DataLocalizer.localize(path: "APP.HELP_MODAL.JOIN_DISCORD_DESCRIPTION"),
                                                onTapAction: { [weak self] in
                                                    self?.handleLink(link: community)
                                                }))
        }

        if let feedback = AbacusStateManager.shared.environment?.links?.feedback {
            items.append(dydxHelpViewModel.Item(icon: "help_feedback",
                                                title: DataLocalizer.localize(path: "APP.HELP_MODAL.PROVIDE_FEEDBACK"),
                                                subtitle: DataLocalizer.localize(path: "APP.HELP_MODAL.PROVIDE_FEEDBACK_DESCRIPTION"),
                                                onTapAction: { [weak self] in
                                                    self?.handleLink(link: feedback)
                                                }))
        }
        if let documentation = AbacusStateManager.shared.environment?.links?.documentation {
            items.append(dydxHelpViewModel.Item(icon: "help_api",
                                                title: DataLocalizer.localize(path: "APP.HEADER.API_DOCUMENTATION"),
                                                subtitle: DataLocalizer.localize(path: "APP.HELP_MODAL.API_DOCUMENTATION_DESCRIPTION"),
                                                onTapAction: { [weak self] in
                                                    self?.handleLink(link: documentation)
                                                }))
        }

        viewModel?.items = items
    }

    private func handleLink(link: String) {
        if let url = URL(string: link), URLHandler.shared?.canOpenURL(url) ?? false {
            URLHandler.shared?.open(url, completionHandler: nil)
        }
    }
}
