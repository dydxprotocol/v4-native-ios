//
//  NavHeader.swift
//  dydxUI
//
//  Created by Rui Huang on 10/2/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class NavHeaderModel: PlatformViewModel {
    @Published public var title: String?
    @Published public var backButtonAction: (() -> Void)?

    public init() { }

    public static var previewValue: NavHeaderModel {
        let vm = NavHeaderModel()
        vm.title = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    if let backButtonAction = self.backButtonAction {
                        ChevronBackButtonModel(onBackButtonTap: backButtonAction)
                            .createView(parentStyle: style)
                    }

                    Text(self.title ?? "")
                        .themeFont(fontSize: .largest)
                        .themeColor(foreground: .textPrimary)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 64)
            )
        }
    }
}

#if DEBUG
struct NavHeader_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return NavHeaderModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct NavHeader_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return NavHeaderModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
