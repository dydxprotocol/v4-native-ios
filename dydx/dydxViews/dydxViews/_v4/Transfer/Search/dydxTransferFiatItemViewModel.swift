//
//  dydxTransferFiatItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 21/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferFiatItemViewModel: PlatformViewModel {
    @Published public var selectAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxTransferFiatItemViewModel {
        let vm = dydxTransferFiatItemViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 8) {
                PlatformIconViewModel(type: .asset(name: "icon_cash", bundle: Bundle.dydxView),
                                      size: CGSize(width: 26, height: 26))
                .createView(parentStyle: style)

                VStack(alignment: .leading) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_WITH_FIAT"))
                        .themeFont(fontSize: .medium)
                        .   themeColor(foreground: .textPrimary)

                    Text("Apple Pay, PayPal, " + DataLocalizer.localize(path: "APP.ONBOARDING.DEBIT"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }

                Spacer()

                HStack {
                    VStack(alignment: .leading) {

                    }

                    PlatformIconViewModel(type: .system(name: "chevron.right"),
                                          size: CGSize(width: 12, height: 12),
                                          templateColor: .textTertiary)
                    .createView(parentStyle: style)
                }
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .themeColor(background: .layer3)
                .cornerRadius(12)
                .onTapGesture { [weak self] in
                    self?.selectAction?()
                }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxTransferFiatItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferFiatItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferFiatItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferFiatItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
