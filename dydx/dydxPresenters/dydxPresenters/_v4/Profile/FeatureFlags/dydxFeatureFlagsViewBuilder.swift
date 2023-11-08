//
//  dydxFeatureFlagsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/30/23.
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

public class dydxFeatureFlagsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxFeatureFlagsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/debug"
        return viewController as? T
    }
}

private class dydxFeatureFlagsViewPresenter: SettingsViewPresenter {
    init() {
        super.init(definitionFile: "features.json",
                   keyValueStore: FeatureFlagsStore.shared,
                   appScheme: Bundle.main.scheme)

        let header = SettingHeaderViewModel()
        header.text = "Feature Flags"
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
