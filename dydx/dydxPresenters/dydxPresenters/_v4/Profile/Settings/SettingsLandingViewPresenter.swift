//
//  SettingsLandingViewPresenter.swift
//  PlatformUIJedio
//
//  Created by Michael Maguire on 7/13/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio
import JedioKit
import dydxStateManager

class SettingsLandingViewPresenter: SettingsViewPresenter {

    private enum DeepLink: String {
        case language = "/settings/language"
        case theme = "/settings/theme"
        case env = "/settings/env"
        case colorPreference = "/settings/direction_color_preference"

        var settingsStoreKey: String {
            switch self {
            case .language: return "language"
            case .theme: return "v4_theme"
            case .env: return "AbacusStateManager.EnvState"
            case .colorPreference: return "direction_color_preference"
            }
        }

        var localizerKeyLookup: [String: String]? {
            switch self {
            // extracting the localizer key lookup from the definition file reduces sources of truth for the key value mapping
            case .language: return SettingsLandingViewPresenter.extractLocalizerKeyLookup(fromDefinitionFile: "settings_language.json")
            case .theme: return SettingsLandingViewPresenter.extractLocalizerKeyLookup(fromDefinitionFile: "settings_theme.json")
            // this one is hardcoded for now, there is no field input definition file for environment selection yet
            case .env: return nil
            case .colorPreference: return SettingsLandingViewPresenter.extractLocalizerKeyLookup(fromDefinitionFile: "settings_direction_color_preference.json")
            }
        }
    }

    /// given a field input definition file, this will extract the dictionary of text/value pairs from the first field options list
    private static func extractLocalizerKeyLookup(fromDefinitionFile definitionFile: String ) -> [String: String] {
        let languageFieldsEntity = newFieldsEntity(forDefinitionFile: definitionFile)

        let fieldsListInteractor = languageFieldsEntity.list?.list?.first as? FieldListInteractor
        let field = fieldsListInteractor?.list?.first as? FieldInput
        var dictionary = [String: String]()
        field?.options?.forEach({ option in
            guard let key = option["value"] as? String else { return }
            guard let value = option["text"] as? String else { return }
            dictionary[key] = value
        })
        return dictionary
    }

    override func createOutputItem(output: FieldOutput) -> FieldOutputTextViewModel {
        let textViewModel = super.createOutputItem(output: output)

        guard let link = output.link,
              let deepLink = DeepLink(rawValue: link),
              let localizerKey = SettingsStore.shared?.value(forKey: deepLink.settingsStoreKey) as? String
        else { return textViewModel }

        if let displayTextKey = deepLink.localizerKeyLookup?[localizerKey] {
            textViewModel.text = DataLocalizer.shared?.localize(path: displayTextKey, params: nil)
        } else if let env = AbacusStateManager.shared.availableEnvironments.first(where: { $0.type == localizerKey }) {
            textViewModel.text = env.localizedString
        }

        return textViewModel
    }
}
