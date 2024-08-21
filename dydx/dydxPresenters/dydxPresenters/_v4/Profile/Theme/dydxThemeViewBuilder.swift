//
//  dydxThemeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/27/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio

public class dydxThemeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxThemeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/theme"
        return viewController as? T
    }
}

private class dydxThemeViewPresenter: FieldSettingsViewPresenter {
    init() {
        super.init(definitionFile: "settings_theme.json", fieldName: "v4_theme", keyValueStore: SettingsStore.shared)

        let header = SettingHeaderViewModel()
        header.text = DataLocalizer.localize(path: "APP.V4.SELECT_A_THEME")
        header.dismissAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.headerViewModel = header
    }

    override func onOptionSelected(option: [String: Any], changed: Bool) {
        if changed {
            dydxThemeLoader.updateTheme()
        }
    }
}
