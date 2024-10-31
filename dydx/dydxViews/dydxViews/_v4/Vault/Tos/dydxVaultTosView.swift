//
//  dydxVaultTosView.swift
//  dydxUI
//
//  Created by Rui Huang on 31/10/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxVaultTosViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var operatorDesc: String?
    @Published public var operatorLearnMore: String?
    @Published public var vaultDesc: String?
    @Published public var operatorAction: (() -> Void)?
    @Published public var vaultAction: (() -> Void)?
    @Published public var ctaAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxVaultTosViewModel {
        let vm = dydxVaultTosViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view =
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(self.vaultDesc ?? "")
                            .themeFont(fontType: .base, fontSize: .small)

                        Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.LEARN_MORE_ABOUT_MEGAVAULT", params: nil) ?? "")
                            .themeFont(fontType: .base, fontSize: .small)
                            .themeColor(foreground: ThemeColor.SemanticColor.colorPurple)
                            .onTapGesture {
                                self.vaultAction?()
                            }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(self.operatorDesc ?? "")
                            .themeFont(fontType: .base, fontSize: .small)

                        Text(self.operatorLearnMore ?? "")
                            .themeFont(fontType: .base, fontSize: .small)
                            .themeColor(foreground: ThemeColor.SemanticColor.colorPurple)
                            .onTapGesture {
                                self.operatorAction?()
                            }
                    }

                    Spacer()
                         .frame(height: 16)

                    let cancelText = Text(DataLocalizer.localize(path: "APP.GENERAL.OK", params: nil))
                    PlatformButtonViewModel(content: cancelText.wrappedViewModel, state: .primary) { [weak self] in
                        self?.ctaAction?()
                    }
                    .createView(parentStyle: style)
                }
                    .padding([.leading, .trailing])
                    .padding(.top, 40)
                    .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                    .themeColor(background: .layer3)
                    .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxVaultTosView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxVaultTosViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxVaultTosView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxVaultTosViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
