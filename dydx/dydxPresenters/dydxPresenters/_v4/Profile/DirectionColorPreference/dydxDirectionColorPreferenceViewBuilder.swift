//
//  dydxDirectionColorPreferenceViewBuilder.swift
//  dydxPresenters
//
//  Created by Mike Maguire on 6/19/2023.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio

public class dydxDirectionColorPreferenceViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxDirectionColorPreferenceViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/direction_color_preference"
        return viewController as? T
    }
}

private class dydxDirectionColorPreferenceViewPresenter: FieldSettingsViewPresenter {
    init() {
        super.init(definitionFile: "settings_direction_color_preference.json", fieldName: "direction_color_preference", keyValueStore: SettingsStore.shared)

        let header = SettingHeaderViewModel()
        header.text = DataLocalizer.localize(path: "APP.V4.DIRECTION_COLOR_PREFERENCE")
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
