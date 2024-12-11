//
//  dydxLanguageViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/20/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio
import dydxStateManager
import Abacus

public class dydxLanguageViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxLanguageViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/language"
        return viewController as? T
    }
}

private class dydxLanguageViewPresenter: BaseSettingsViewPresenter {

    private let localizer = DataLocalizer.shared as? AbacusLocalizerProtocol

    private var filteredLanguages: [SelectionOption] {
        let restrictedLocales = AbacusStateManager.shared.environment?.restrictedLocales
        return localizer?.languages.filter { language -> Bool in
            restrictedLocales.isNilOrEmpty || restrictedLocales?.contains(language.type) == false
        } ?? []
    }

    init() {
        super.init(definitionFile: "")

        let header = SettingHeaderViewModel()
        header.text = DataLocalizer.localize(path: "APP.ONBOARDING.SELECT_A_LANGUAGE")
        header.dismissAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.headerViewModel = header

        let listModel = PlatformListViewModel(firstListItemTopSeparator: true, lastListItemBottomSeparator: true)
        listModel.width = UIScreen.main.bounds.width - 16
        listModel.items = filteredLanguages.map { option in
            let itemViewModel = SettingOptionViewModel()
            itemViewModel.text = option.localizedString
            itemViewModel.isSelected = option.type == localizer?.language
            itemViewModel.onTapAction = {
                DataLocalizer.shared?.setLanguage(language: option.type, completed: { successful in
                    if successful {
                        Router.shared?.navigate(to: RoutingRequest(path: "/loading"), animated: true, completion: { _, _ in
                            Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true, completion: { _, _ in
                            })
                        })
                    }
                })
            }
            return itemViewModel
        }

        let section = SettingsViewModel.SectionViewModel(items: listModel)
        viewModel?.sections = [section]
    }
}
