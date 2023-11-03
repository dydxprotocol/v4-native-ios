//
//  TokensComboBox.swift
//  dydxUI
//
//  Created by Rui Huang on 4/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class TokensComboBoxModel: PlatformViewModel {
    @Published public var onTapAction: (() -> Void)?
    @Published public var icon: PlatformIconViewModel?
    @Published public var label: String?
    @Published public var text: String?
    @Published public var tokenText: TokenTextViewModel?

    public init(onTapAction: (() -> Void)? = nil, icon: PlatformIconViewModel? = nil, label: String? = nil, text: String? = nil, tokenText: TokenTextViewModel? = nil) {
        self.onTapAction = onTapAction
        self.icon = icon
        self.label = label
        self.text = text
        self.tokenText = tokenText
    }

    public static var previewValue: TokensComboBoxModel {
        let vm = TokensComboBoxModel()
        vm.icon = PlatformIconViewModel(type: .system(name: "radio"), size: CGSize(width: 24, height: 24))
        vm.label = "Label"
        vm.text = "Text"
        vm.tokenText = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let content = HStack {
                self.icon?.createView(parentStyle: style)

                Text(self.text ?? "")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)

                self.tokenText?.createView(parentStyle: style.themeFont(fontSize: .smaller))
            }
                .frame(height: 32)
            return AnyView(
                ComboBoxModel(title: self.label ?? "",
                              content: content.wrappedViewModel,
                              onTapAction: self.onTapAction)
                    .createView(parentStyle: style)
            )
        }
    }
}

#if DEBUG
struct TokensComboBox_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return TokensComboBoxModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct TokensComboBox_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return TokensComboBoxModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
