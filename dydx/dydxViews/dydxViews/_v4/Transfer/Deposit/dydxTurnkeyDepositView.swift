//
//  dydxTurnkeyDepositView.swift
//
//  Created by Rui Huang on 04/08/2025.
//  Copyright Fambot.  All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTurnkeyDepositViewModel: PlatformViewModel {
    @Published public var text: String?

    public init() { }

    public static var previewValue: dydxTurnkeyDepositViewModel {
        let vm = dydxTurnkeyDepositViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                VStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .larger)
                        .centerAligned()
                        .padding(.vertical, 8)
                        .padding(.top, 8)
                        .frame(height: 54)

                    DividerModel().createView(parentStyle: style)
                        .padding(.horizontal, -16)
                }

                Spacer()
            }
                .padding(.horizontal)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer2)
                .ignoresSafeArea(edges: [.bottom])

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxTurnkeyDepositView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTurnkeyDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTurnkeyDepositView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTurnkeyDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
