//
//  dydxSimpleUIClosePercentView.swift
//  dydxUI
//
//  Created by Rui Huang on 22/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIClosePercentViewModel: PlatformOptionsInputViewModel {
    public static var previewValue: dydxSimpleUIClosePercentViewModel = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "1", string: "100%"))
        options.append(InputSelectOption(value: "0.50", string: "50%"))
        options.append(InputSelectOption(value: "0.25", string: "25%"))
        let vm = dydxSimpleUIClosePercentViewModel(label: nil, value: nil, options: options, onEdited: nil)
        return vm
    }()

    private func unselected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .plus, fontSize: .small)
            .padding(8)
            .themeColor(foreground: .textTertiary)
            .themeColor(background: .layer4)
            .cornerRadius(8)
            .wrappedViewModel
    }

    private func selected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .plus, fontSize: .small)
            .padding(8)
            .themeColor(background: .layer0)
            .cornerRadius(8)
            .wrappedViewModel
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = optionTitles?.compactMap {
                self.unselected(item: $0)
            }
            let selectedItems = optionTitles?.compactMap {
                self.selected(item: $0)
            }
            let view = TabGroupModel(items: items,
                                     selectedItems: selectedItems,
                                     currentSelection: self.index,
                                     onSelectionChanged: { [weak self] index in
                self?.value = self?.options?[index].value
                self?.onEdited?(self?.value)
            },
                                     layoutConfig: .naturalSize)
            .createView(parentStyle: style)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIClosePercentView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIClosePercentViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIClosePercentView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIClosePercentViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
