//
//  FieldSettingsViewPresenter.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/20/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import JedioKit

open class FieldSettingsViewPresenter: BaseSettingsViewPresenter {
    private let fieldName: String
    private let keyValueStore: KeyValueStoreProtocol?
    
    private var fieldInput: FieldInput?
    
    public init(definitionFile: String, fieldName: String, keyValueStore: KeyValueStoreProtocol?) {
        self.fieldName = fieldName
        self.keyValueStore = keyValueStore
        super.init(definitionFile: definitionFile)
        
        fieldInput = findInput(fieldName: fieldName)
        loadOptions()
    }
    
    private func loadOptions() {
        let listModel = PlatformListViewModel(firstListItemTopSeparator: true, lastListItemBottomSeparator: true)
        listModel.width = UIScreen.main.bounds.width - 16
        let options: [[String: Any]]? = fieldInput?.options
        listModel.items = (options ?? []).compactMap { option in
            guard let text = textForOption(option: option),
                  let value = valueForOption(option: option) else {
                return nil
            }
            
            let optionViewModel = SettingOptionViewModel()
            optionViewModel.text = DataLocalizer.localize(path: text)
            optionViewModel.isSelected = parser.asString(keyValueStore?.value(forKey: fieldName)) == value
            optionViewModel.onTapAction = { [weak self] in
                guard let self = self else {
                    return
                }
                if let currentValue = self.keyValueStore?.value(forKey: self.fieldName) as? String,
                   let newValue = option["value"] as? String,
                   currentValue == newValue {
                    self.onOptionSelected(option: option, changed: false)
                } else {
                    self.keyValueStore?.setValue(option["value"], forKey: self.fieldName)
                    optionViewModel.isSelected = true
                    self.onOptionSelected(option: option, changed: true)
                    self.loadOptions()
                }
            }
            return optionViewModel
        }
        viewModel?.sections = [SettingsViewModel.SectionViewModel(items: listModel)]
    }
    
    open func onOptionSelected(option: [String: Any], changed: Bool) {
    }
    
    open func textForOption(option:  [String: Any]) -> String? {
        parser.asString(option["text"])
    }
    
    open func valueForOption(option:  [String: Any]) -> String? {
        parser.asString(option["value"])
    }

    private func findInput(fieldName: String) -> FieldInput? {
        for fieldList in fieldLists ?? [] {
            for object2 in fieldList.list ?? [] {
                if let input = object2 as? FieldInput {
                    if input.field?.definition(for: "field")?["field"] as? String == fieldName {
                        return input
                    }
                }
            }
        }
        return nil
    }
}
