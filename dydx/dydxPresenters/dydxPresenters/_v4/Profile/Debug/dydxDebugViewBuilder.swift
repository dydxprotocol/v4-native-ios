//
//  dydxDebugViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/29/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio
import SwiftUI

public class dydxDebugViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxDebugViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/debug"
        return viewController as? T
    }
}

private class dydxDebugViewPresenter: SettingsViewPresenter {
    init() {
        super.init(definitionFile: "debug.json", keyValueStore: SettingsStore.shared)

        let header = SettingHeaderViewModel()
        header.text = "Debug Settings"
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
