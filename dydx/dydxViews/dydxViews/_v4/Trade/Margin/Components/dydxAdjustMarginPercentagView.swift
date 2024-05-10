//
//  dydxAdjustMarginPercentagView.swift
//  dydxUI
//
//  Created by Rui Huang on 09/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginPercentagViewModel: PlatformViewModel {
    public struct PercentageOption {
        let text: String
        let percentage: Double

        public init(text: String, percentage: Double) {
            self.text = text
            self.percentage = percentage
        }
    }

    @Published public var percentageOptions: [PercentageOption] = []
    @Published public var selectedPercentageOptionIndex: Int?
    @Published public var percentageOptionSelectedAction: ((PercentageOption) -> Void)?

    public init() { }

    public static var previewValue: dydxAdjustMarginPercentagViewModel {
        let vm = dydxAdjustMarginPercentagViewModel()
        vm.percentageOptions = [
            PercentageOption(text: "25%", percentage: 0.25),
            PercentageOption(text: "50%", percentage: 0.5),
            PercentageOption(text: "75%", percentage: 0.75),
            PercentageOption(text: "100%", percentage: 1.0)
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.percentageOptions.compactMap {
                Text($0.text)
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
                    .padding(8)
                    .frame(minWidth: 60)
                    .themeColor(background: .layer5)
                    .border(borderWidth: 1, cornerRadius: 8, borderColor: ThemeColor.SemanticColor.layer5.color)
                    .wrappedViewModel
            }
            let selectedItems = self.percentageOptions.compactMap {
                Text($0.text)
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textPrimary)
                    .padding(8)
                    .frame(minWidth: 60)
                    .themeColor(background: .layer1)
                    .border(borderWidth: 1, cornerRadius: 8, borderColor: ThemeColor.SemanticColor.layer5.color)
                    .wrappedViewModel
            }

            let view = ScrollView(.horizontal, showsIndicators: false) {
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.selectedPercentageOptionIndex,
                              onSelectionChanged: { index in
                    self.percentageOptionSelectedAction?(self.percentageOptions[index])
                })
                .createView(parentStyle: parentStyle)
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxAdjustMarginPercentagView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginPercentagViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginPercentagView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginPercentagViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
