//
//  dydxFiatDepositItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 25/09/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxFiatDepositItemViewModel: PlatformViewModel {
    @Published public var selectAction: (() -> Void)?

    public init(selectAction: (() -> Void)? = nil) {
        self.selectAction = selectAction
    }

    public static var previewValue: dydxFiatDepositItemViewModel {
        let vm = dydxFiatDepositItemViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 8) {
                Spacer()

                PlatformIconViewModel(type: .asset(name: "icon_cash", bundle: Bundle.dydxView),
                                      size: CGSize(width: 16, height: 16))
                .createView(parentStyle: style)

                HStack(spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_WITH_FIAT"))
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textPrimary)

                    PlatformIconViewModel(type: .asset(name: "icon_next", bundle: Bundle.dydxView),
                                          size: CGSize(width: 20, height: 20),
                                          templateColor: .textPrimary)
                    .createView(parentStyle: style)
                }

                Spacer()
            }
                .frame(height: 48)
                .themeColor(background: .layer3)
                .cornerRadius(12)

            let button = Button {
                self.selectAction?()
            } label: {
                view
            }

            return AnyView(button)

        }
    }
}

#if DEBUG
struct dydxFiatDepositItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxFiatDepositItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxFiatDepositItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxFiatDepositItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
