//
//  dydxNotificationsSettingsViewBuilder.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 3/28/24.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio
import SwiftUI
import dydxStateManager

public class dydxNotificationsSettingsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxNotificationsSettingsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/notifications"
        return viewController as? T
    }
}

private class dydxNotificationsSettingsViewPresenter: SettingsViewPresenter {
    init() {
        super.init(definitionFile: "notifications.json",
                   keyValueStore: SettingsStore.shared,
                   appScheme: Bundle.main.scheme)

        let header = SettingHeaderViewModel()
        header.text = DataLocalizer.shared?.localize(path: "APP.V4.NOTIFICATIONS", params: nil)
        header.dismissAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.headerViewModel = header
    }
}
