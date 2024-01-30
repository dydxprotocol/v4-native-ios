//
//  dydxSettingsLandingViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/21/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio
import SwiftUI
import PlatformRouting
import dydxStateManager

public class dydxSettingsLandingViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSettingsLandingViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings"
        return viewController as? T
    }
}

private class dydxSettingsLandingViewPresenter: SettingsLandingViewPresenter {

    init() {
        let definitionFile: String
        switch Installation.source {
        case .debug:
            definitionFile = "settings_debug.json"
            
        case .testFlight:
            definitionFile = DebugEnabled.enabled ? "settings_debug.json" : "settings.json"
            
        default:
            // Other than during debugging and DebugEnabled for TestFlight build, we should never show the debug screen
            definitionFile = "settings.json"
        }
        
        super.init(definitionFile: definitionFile,
                   keyValueStore: SettingsStore.shared,
                   appScheme: Bundle.main.scheme)

        let header = SettingHeaderViewModel()
        header.text = DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.SETTINGS")
        header.dismissAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.headerViewModel = header

        viewModel?.footerViewModel = PlatformViewModel { _ in
            AnyView(
                Text(AppInfo.shared.version ?? "")
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    .leftAligned()
                    .padding(.horizontal, 16)
            )
        }
    }
}
