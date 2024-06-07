//
//  dydxTargetLeverageView.swift
//  dydxUI
//
//  Created by Rui Huang on 07/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTargetLeverageViewModel: PlatformViewModel {
    public struct LeverageTextAndValue {
        public let text: String
        public let value: Double

        public init(text: String, value: Double) {
            self.text = text
            self.value = value
        }
    }

    @Published public var description: String?
    @Published public var leverageOptions: [LeverageTextAndValue] = []
    @Published public var selectedOptionIndex: Int?
    @Published public var optionSelectedAction: ((LeverageTextAndValue) -> Void)?
    @Published public var leverageInput: PlatformTextInputViewModel? =
        PlatformTextInputViewModel(label: DataLocalizer.localize(path: "APP.TRADE.TARGET_LEVERAGE"),
                                   placeHolder: "0.0",
                                   inputType: PlatformTextInputViewModel.InputType.decimalDigits)
    @Published public var ctaButton: dydxTargetLeverageCtaButtonViewModel? = dydxTargetLeverageCtaButtonViewModel()

    public init() { }

    public static var previewValue: dydxTargetLeverageViewModel {
        let vm = dydxTargetLeverageViewModel()
        vm.description = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 20) {
                Text(DataLocalizer.localize(path: "APP.TRADE.ADJUST_TARGET_LEVERAGE"))
                        .themeColor(foreground: .textPrimary)
                        .leftAligned()
                        .themeFont(fontType: .plus, fontSize: .largest)
                        .padding(.top, 40)

                Text(self.description ?? "")
                    .themeColor(foreground: .textTertiary)
                    .leftAligned()
                    .themeFont(fontSize: .medium)

                self.leverageInput?
                    .createView(parentStyle: style)
                    .makeInput()

                self.createOptionsGroup(parentStyle: style)

                Spacer()

                self.ctaButton?.createView(parentStyle: style)
            }
                .padding(.horizontal)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
                .makeSheet()

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createOptionsGroup(parentStyle: ThemeStyle) -> some View {
        let spacing: CGFloat = 8
        let maxItemsToDisplay = CGFloat(max(5, leverageOptions.count))

        return GeometryReader { geometry in
            let width = (geometry.size.width + spacing) / maxItemsToDisplay - spacing
            let items = self.leverageOptions.compactMap {
                Text($0.text)
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    .padding(8)
                    .frame(minWidth: width)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .cornerRadius(8), borderColor: ThemeColor.SemanticColor.layer5)
                    .wrappedViewModel
            }

            let selectedItems = self.leverageOptions.compactMap {
                Text($0.text)
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textPrimary)
                    .padding(8)
                    .frame(minWidth: width)
                    .themeColor(background: .layer1)
                    .borderAndClip(style: .cornerRadius(8), borderColor: ThemeColor.SemanticColor.layer5)
                    .wrappedViewModel
            }

            return ScrollView(.horizontal, showsIndicators: false) {
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.selectedOptionIndex,
                              onSelectionChanged: { index in
                    self.optionSelectedAction?(self.leverageOptions[index])
                },
                              spacing: spacing)
                .createView(parentStyle: parentStyle)
            }
        }
    }
}

#if DEBUG
struct dydxTargetLeverageView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTargetLeverageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTargetLeverageView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTargetLeverageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
