//
//  dydxAdjustMarginPercentageView.swift
//  dydxUI
//
//  Created by Rui Huang on 09/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginPercentageViewModel: PlatformViewModel {
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

    public static var previewValue: dydxAdjustMarginPercentageViewModel {
        let vm = dydxAdjustMarginPercentageViewModel()
        vm.percentageOptions = [
            PercentageOption(text: "5%", percentage: 0.05),
            PercentageOption(text: "10%", percentage: 0.10),
            PercentageOption(text: "25%", percentage: 0.25),
            PercentageOption(text: "50%", percentage: 0.50),
            PercentageOption(text: "75%", percentage: 0.75)
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let spacing: CGFloat = 8
            let itemPadding: CGFloat = 8
            let maxItemsToDisplay = CGFloat(min(5, percentageOptions.count))

            return SingleAxisGeometryReader { width in
                let width = (width + spacing) / maxItemsToDisplay - spacing
                let items = self.percentageOptions.compactMap {
                    Text($0.text)
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textSecondary)
                        .padding(itemPadding)
                        .frame(minWidth: width)
                        .themeColor(background: .layer5)
                        .borderAndClip(style: .cornerRadius(8), borderColor: .layer5)
                        .fixedSize(horizontal: false, vertical: true)
                        .wrappedViewModel
                }
                let selectedItems = self.percentageOptions.compactMap {
                    Text($0.text)
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textPrimary)
                        .padding(itemPadding)
                        .frame(minWidth: width)
                        .themeColor(background: .layer1)
                        .borderAndClip(style: .cornerRadius(8), borderColor: .layer5)
                        .fixedSize(horizontal: false, vertical: true)
                        .wrappedViewModel
                }

                return TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.selectedPercentageOptionIndex,
                              onSelectionChanged: { index in
                    self.percentageOptionSelectedAction?(self.percentageOptions[index])
                })
                .createView(parentStyle: parentStyle)
            }
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxAdjustMarginPercentageView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginPercentageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginPercentageView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginPercentageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
