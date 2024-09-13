//
//  SettingsViewPresenter.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/21/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import JedioKit

open class SettingsViewPresenter: BaseSettingsViewPresenter {
    private let keyValueStore: KeyValueStoreProtocol?
    private let appScheme: String?

    public init(definitionFile: String, keyValueStore: KeyValueStoreProtocol?, appScheme: String?) {
        self.keyValueStore = keyValueStore
        self.appScheme = appScheme
        super.init(definitionFile: definitionFile)
    }

    override open func start() {
        super.start()

        loadSettings()
    }

    private func loadSettings() {
        var sections = [SettingsViewModel.SectionViewModel]()
        for fieldList in fieldLists ?? [] {
            sections.append(createSection(group: fieldList))
        }
        viewModel?.sections = sections
    }

    private func createSection(group: FieldListInteractor) -> SettingsViewModel.SectionViewModel {
        let listViewModel = PlatformListViewModel(firstListItemTopSeparator: true, lastListItemBottomSeparator: true)
        listViewModel.width = UIScreen.main.bounds.width - 16
        for item in group.list ?? [] {
            if let output = item as? FieldOutput,
               let viewModel = createOutput(output: output) {
                listViewModel.items.append(viewModel)
            } else if let input = item as? FieldInput,
                      let viewModel = createInput(input: input) {
                listViewModel.items.append(viewModel)
            }
        }
        return SettingsViewModel.SectionViewModel(title: group.title, items: listViewModel)
    }

    private func createInput(input: FieldInput) -> PlatformViewModel? {
        guard let fieldInputDefinition = input.fieldInput else {
            return nil
        }

        if let fieldName = input.fieldName,
           let value = keyValueStore?.value(forKey: fieldName) {
            input.value = value
        }

        let valueChanged: ((Any?) -> Void)? = { [weak self] value in
            input.value = value
            if let fieldName = input.fieldName {
                self?.keyValueStore?.setValue(value, forKey: fieldName)
            }
            self?.loadSettings()
            self?.onInputValueChanged(input: input)
        }

        if let xib = fieldInputDefinition.xib {
            // TODO: ...
        } else if fieldInputDefinition.link != nil {
            // TODO: ...
        } else {
            let hasOptions = fieldInputDefinition.options != nil
            switch fieldInputDefinition.fieldType {
            case .text:
                if hasOptions {
                    return FieldInputSelectionGridViewModel(input: input, valueChanged: valueChanged)
                } else {
                    return FieldInputTextsInputViewModel(input: input, valueChanged: valueChanged)
                }

            //            case .int:
            //                if hasOptions {
            //                    return "field_input_grid_int"
            //                } else if fieldInput.min != nil && fieldInput.max != nil {
            //                    return "field_input_slider_int"
            //                } else {
            //                    return "field_input_textfield_int"
            //                }
            //
            //            case .float:
            //                if fieldInput.min != nil && fieldInput.max != nil {
            //                    return "field_input_slider_float"
            //                } else {
            //                    return "field_input_textfield_float"
            //                }
            //
            //            case .percent:
            //                return "field_input_slider_percent"
            //
            //            case .strings:
            //                return "field_input_grid_strings"

            case .bool:
                return FieldInputSwitchViewModel(input: input, valueChanged: valueChanged)

            //            case .image:
            //                #if _iOS
            //                    return "field_button_image"
            //                #else
            //                    return "field_blank"
            //                #endif
            //
            //            case .images:
            //                #if _iOS
            //                    return "field_input_grid_images"
            //                #else
            //                    return "field_blank"
            //                #endif
            //
            //            case .signature:
            //                #if _iOS
            //                    return "field_input_button_signature"
            //                #else
            //                    return "field_blank"
            //                #endif

            default:
                // assertionFailure("Not implemented")
                break
            }
        }
        return nil
    }

    private func createOutput(output: FieldOutput) -> PlatformViewModel? {
        if let xib = output.field?.xib {
            // TODO: ...
        } else {
            return createOutputItem(output: output)
        }
        return nil
    }

    open func createOutputItem(output: FieldOutput) -> FieldOutputTextViewModel {
        let textViewModel = FieldOutputTextViewModel(output: output)
        if let appScheme = appScheme, let link = output.link?.replacingOccurrences(of: "{APP_SCHEME}", with: appScheme) {
            let routingRequest = RoutingRequest(url: link)
            textViewModel.onTapAction = {
                Router.shared?.navigate(to: routingRequest, animated: true, completion: nil)
            }
        }
        return textViewModel
    }
    
    open func onInputValueChanged(input: FieldInput) {
        
    }
}
