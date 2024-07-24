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
import dydxFormatter

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
    @Published public var sliderTextInput = dydxSliderInputViewModel(
        title: DataLocalizer.localize(path: "APP.TRADE.TARGET_LEVERAGE")
    )
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

                self.sliderTextInput
                    .createView(parentStyle: style)

                self.createOptionsGroup(parentStyle: style)

                Spacer()

                self.ctaButton?.createView(parentStyle: style)
            }
                .padding(.horizontal)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
                .makeSheet()
                .onTapGesture {
                    PlatformView.hideKeyboard()
                }

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createOptionsGroup(parentStyle: ThemeStyle) -> some View {
        let spacing: CGFloat = 8
        let maxItemsToDisplay = CGFloat(leverageOptions.count)

        return SingleAxisGeometryReader { width in
            let width = (width + spacing) / maxItemsToDisplay - spacing
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

            return HStack(spacing: spacing) {
                ForEach(items.indices, id: \.self) { index in
                    PlatformButtonViewModel(content: items[index], type: .iconType, state: .secondary) { [weak self] in
                        guard let option = self?.leverageOptions[index] else { return }
                        PlatformView.hideKeyboard()
                        self?.optionSelectedAction?(option)
                    }
                    .createView()
                }
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
