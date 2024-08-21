//
//  dydxOnboardScanInstructionsView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/13/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOnboardScanInstructionsViewModel: PlatformViewModel {
    @Published public var ctaAction: (() -> Void)?
    @Published public var backAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxOnboardScanInstructionsViewModel {
        let vm = dydxOnboardScanInstructionsViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 16) {
                HStack {
                    let buttonContent = PlatformIconViewModel(type: .system(name: "chevron.left"), size: CGSize(width: 16, height: 16))
                    PlatformButtonViewModel(content: buttonContent, type: .iconType) { [weak self] in
                        self?.backAction?()
                    }
                    .createView(parentStyle: style)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.OPEN_QR_CODE"))
                        .themeFont(fontType: .plus, fontSize: .largest)
                }
                .leftAligned()

                Text(DataLocalizer.localize(path: "APP.ONBOARDING.OPEN_QR_CODE_DESC"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textTertiary)

                Image("image_qrcode_desktop", bundle: Bundle.dydxView)
                    .rightAligned()
                    .padding(.vertical, 16)

                let buttonContent =
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.OPEN_QR_CODE_NEXT"))
                        .wrappedViewModel
                PlatformButtonViewModel(content: buttonContent, type: .defaultType(fillWidth: true)) { [weak self] in
                    self?.ctaAction?()
                }
                .createView(parentStyle: style)

                Spacer()
            }
                .padding([.leading, .trailing])
                .padding(.top, 40)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxOnboardScanInstructionsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardScanInstructionsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOnboardScanInstructionsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardScanInstructionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
