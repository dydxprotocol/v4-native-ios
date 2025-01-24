//
//  dydxProfileHelpView.swift
//  dydxUI
//
//  Created by Rui Huang on 24/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileHelpViewModel: PlatformViewModel {
    @Published public var helpAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxProfileHelpViewModel {
        let vm = dydxProfileHelpViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 8) {
                PlatformIconViewModel(type: .asset(name: "icon_tutorial", bundle: Bundle.dydxView),
                                      clip: .noClip,
                                      size: CGSize(width: 24, height: 24),
                                      templateColor: .textTertiary)
                .createView()

                Text(DataLocalizer.localize(path: "APP.HEADER.HELP"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textPrimary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 22)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                self.helpAction?()
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxProfileHelpView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHelpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileHelpView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHelpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
