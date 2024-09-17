//
//  dydxNotificationPrimerViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 11/09/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxNotificationPrimerViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxNotificationPrimerViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxNotificationPrimerViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxNotificationPrimerViewController: HostingViewController<PlatformView, dydxNotificationPrimerViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/primer/notification" {
            return true
        }
        return false
    }
}

private protocol dydxNotificationPrimerViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxNotificationPrimerViewModel? { get }
}

private class dydxNotificationPrimerViewPresenter: HostedViewPresenter<dydxNotificationPrimerViewModel>, dydxNotificationPrimerViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxNotificationPrimerViewModel()
        viewModel?.ctaAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) { _, _ in
                let notificationPermission = NotificationService.shared?.authorization
                if notificationPermission?.authorization == .notDetermined {
                    notificationPermission?.promptToAuthorize()
                }
            }
        }
    }
}
