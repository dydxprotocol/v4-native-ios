//
//  dydxEmailInputView.swift
//  dydxUI
//
//  Created by Rui Huang on 06/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxEmailInputViewModel: PlatformTextInputViewModel {
    @Published public var isValid: Bool = false
    @Published public var submitAction: (() -> Void)?

    public init() {
        super.init(placeHolder: "your@email.com",
                   inputType: .emailAddress,
                   contentType: .emailAddress,
                   padding: EdgeInsets(horizontal: 8, vertical: 16))
    }

    public static var previewValue: dydxEmailInputViewModel {
        let vm = dydxEmailInputViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { style in
            let view = HStack {
                PlatformIconViewModel(type: .asset(name: "icon_email", bundle: Bundle.dydxView),
                                      size: CGSize(width: 28, height: 28))
                .createView(parentStyle: style)
                .padding(.leading, 16)

                view

                Group {
                    if self.isValid {
                        Button { [weak self] in
                            self?.submitAction?()
                        } label: {
                            Text(DataLocalizer.localize(path: "APP.COMPLIANCE_MODAL.SUBMIT"))
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .colorPurple)
                        }
                    } else {
                        Text(DataLocalizer.localize(path: "APP.COMPLIANCE_MODAL.SUBMIT"))
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textTertiary)
                            .opacity(0.5)
                    }
                }
                .padding(.trailing, 16)
            }
                .themeColor(background: .layer3)
                .borderAndClip(style: .cornerRadius(16), borderColor: .borderDefault)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxEmailInputView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxEmailInputViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxEmailInputView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxEmailInputViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
