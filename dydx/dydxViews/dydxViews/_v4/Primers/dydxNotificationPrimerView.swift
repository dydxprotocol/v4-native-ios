//
//  dydxNotificationPrimerView.swift
//  dydxUI
//
//  Created by Rui Huang on 11/09/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxNotificationPrimerViewModel: PlatformViewModel {
    @Published public var ctaAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxNotificationPrimerViewModel {
        let vm = dydxNotificationPrimerViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view =
                VStack(alignment: .leading, spacing: 16) {
                    Text(DataLocalizer.localize(path: "APP.PUSH_NOTIFICATIONS.PRIMER_TITLE", params: nil))
                        .themeFont(fontType: .plus, fontSize: .largest)

                    Text(DataLocalizer.localize(path: "APP.PUSH_NOTIFICATIONS.PRIMER_MESSAGE", params: nil))
                        .themeFont(fontType: .base, fontSize: .medium)
                        .fixedSize(horizontal: false, vertical: true)

                    let buttonText = Text(DataLocalizer.localize(path: "APP.GENERAL.OK", params: nil))
                    PlatformButtonViewModel(content: buttonText.wrappedViewModel) { [weak self] in
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
struct dydxNotificationPrimerView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxNotificationPrimerViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxNotificationPrimerView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxNotificationPrimerViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
