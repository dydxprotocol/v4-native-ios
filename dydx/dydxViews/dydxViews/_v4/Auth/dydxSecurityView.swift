//
//  dydxSecurityView.swift
//  dydxUI
//
//  Created by Michael Maguire on 10/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import LocalAuthentication
import SwiftUI
import PlatformUI
import Utilities

public class dydxSecurityViewModel: PlatformViewModel {

    @Published public var authenticateTapped: (() -> Void)?
    @Published public var isAuthenticateButtonVisible: Bool = false
    @Published public var errorLabelText: String?
    @Published public var authenticateButtonText: String?

    public static var previewValue: dydxSecurityViewModel {
        let vm = dydxSecurityViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    self.logoImage(parentStyle: parentStyle, styleKey: styleKey)
                    Spacer()
                    VStack(spacing: 32) {
                        self.errorLabel()
                        self.authenticateButton(parentStyle: parentStyle, styleKey: styleKey)
                    }
                }
                    .padding(16)
            )
        }
    }

    private func errorLabel() -> Text? {
        if let errorLabelText = self.errorLabelText {
            return Text(errorLabelText)
                .themeFont(fontType: .base, fontSize: .large)
                .themeColor(foreground: .textPrimary)
        }
        return nil
    }

    private func authenticateButton(parentStyle: ThemeStyle, styleKey: String?) -> PlatformView? {
        guard let authenticateButtonText else { return nil }
        if self.isAuthenticateButtonVisible {
            let content = HStack {
                Spacer()
                Text(authenticateButtonText)
                Spacer()
            }
            .wrappedViewModel

            return PlatformButtonViewModel(content: content) {[weak self] in
                self?.authenticateTapped?()
            }
            .createView(parentStyle: parentStyle, styleKey: styleKey)
        }
        return nil
    }

    private func logoImage(parentStyle: ThemeStyle, styleKey: String?) -> PlatformView {
        let imageName: String
        if dydxThemeSettings.shared.currentThemeType == .light {
            imageName = "brand_light"
        } else {
            imageName = "brand_dark"
        }
        return PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                              clip: .noClip,
                              size: .init(width: 100, height: 100),
                              templateColor: nil)
        .createView(parentStyle: parentStyle, styleKey: styleKey)
    }
}

#if DEBUG
struct dydxSecurityView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSecurityViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSecurityView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSecurityViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
