//
//  FieldInputSelectionGridView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/29/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class FieldInputSelectionGridViewModel: FieldInputBaseViewModel {
    private struct Option: Hashable {
        var text: String
        var value: String
        var selected: Bool
    }
    
    private var options: [Option] {
        input?.fieldInput?.options?.compactMap { (dict: [String : Any]) in
            if let text = dict["text"] as? String,
                let value = dict["value"] as? String {
                if selectedValue == value || (selectedValue == nil && value == "<null>") {
                    return Option(text: text, value: value, selected: true)
                } else {
                    return Option(text: text, value: value, selected: false)
                }
            } else {
                return nil
            }
        } ?? []
    }
    
    private var optionValues: [String] {
        input?.fieldInput?.options?.compactMap { (dict: [String : Any]) in
            dict["value"] as? String
        } ?? []
    }
    
    private var optionTexts: [(String, Bool)] {
        input?.fieldInput?.options?.compactMap { (dict: [String : Any]) in
            if let text = dict["text"] as? String, let value = dict["value"] as? String {
                if selectedValue == value || (selectedValue == nil && value == "<null>") {
                    return (text, true)
                } else {
                    return (text, false)
                }
            } else {
                return nil
            }
        } ?? []
    }
    
    private var selectedValue: String? {
        input?.value as? String
    }
    
    public static var previewValue: FieldInputSelectionGridViewModel {
        let vm = FieldInputSelectionGridViewModel()
        return vm
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            
            let columns = [GridItem(), GridItem()]
            return AnyView(
                VStack(alignment: .leading) {
                    Text(self.title ?? "")
                        .themeFont(fontSize: .medium)
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(self.options, id: \.self) { option in
                            let color = option.selected ? ThemeColor.SemanticColor.layer5 : ThemeColor.SemanticColor.layer3
                            ZStack {
                                Text(option.text)
                                    .themeFont(fontSize: .medium)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .themeColor(background: color)
                                
                                if option.selected {
                                    PlatformIconViewModel(type: .system(name: "checkmark"), size: CGSize(width: 8, height: 8))
                                        .createView(parentStyle: style)
                                        .topAligned()
                                        .rightAligned()
                                        .padding(8)
                                }
                            }
                            .onTapGesture {
                                if !option.selected {
                                    self.input?.value = option.value
                                    self.valueChanged?(option.value)
                                    self.objectWillChange.send()
                                }
                            }
                        }
                    }
                }
                    .padding()
            )
        }
    }
}

#if DEBUG
struct FieldInputSelectionGridView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return FieldInputSelectionGridViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct FieldInputSelectionGridView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return FieldInputSelectionGridViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

