//
//  dydxTransferNobleItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 14/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferNobleItemViewModel: PlatformViewModel {
    @Published public var nobleAdddressAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxTransferNobleItemViewModel {
        let vm = dydxTransferNobleItemViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 8) {
                PlatformIconViewModel(type: .asset(name: "icon_cex", bundle: Bundle.dydxView),
                                          size: CGSize(width: 26, height: 26),
                                          templateColor: .textTertiary)
                        .createView(parentStyle: style)

                VStack(alignment: .leading) {
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.DEPOSIT_FROM_CEX"))
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textPrimary)
                    Text("Coinbase, OKX, etc.")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }

                Spacer()

                HStack {
                    self.createIcons(style: style)

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
                    self?.nobleAdddressAction?()
                }

            return AnyView(view)
        }
    }

    private func createIcons(style: ThemeStyle) -> some View {
        HStack(spacing: -12) {
            ForEach(["coinbase_wallet", "okx_wallet"], id: \.self) { icon in
                self.createOptionIcon(style: style, icon: icon, templateColor: nil)
            }
        }
    }

    private func createOptionIcon(style: ThemeStyle, icon: String, templateColor: ThemeColor.SemanticColor? = nil) -> some View {
        ZStack {
            Rectangle()
                .frame(width: 28, height: 28)
                .themeColor(foreground: .layer3)
                .clipShape(.circle)

            PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                  size: CGSize(width: 24, height: 24),
                                  templateColor: templateColor)
            .createView(parentStyle: style)
        }
    }
}

#if DEBUG
struct dydxTransferNobleItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferNobleItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferNobleItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferNobleItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
