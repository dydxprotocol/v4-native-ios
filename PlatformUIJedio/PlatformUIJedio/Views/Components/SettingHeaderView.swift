//
//  SettingHeaderView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/20/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SettingHeaderViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var dismissAction: (() -> Void)?
    
    public init() { }

    public static var previewValue: SettingHeaderViewModel {
        let vm = SettingHeaderViewModel()
        vm.text = "Header"
        return vm
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 16) {
                    if let dismissAction = self.dismissAction {
                        let buttonContent = PlatformIconViewModel(type: .system(name: "chevron.left"), size: CGSize(width: 16, height: 16), templateColor: .textTertiary)
                        PlatformButtonViewModel(content: buttonContent, type: .iconType) {
                            dismissAction()
                        }
                        .createView(parentStyle: style)
                        .padding([.leading, .vertical], 8)
                    }
                    
                    Text(self.text ?? "")
                        .themeFont(fontType: .base, fontSize: .largest)
                        .themeColor(foreground: .textPrimary)
                }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
            )
        }
    }
}

#if DEBUG
struct SettingHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SettingHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SettingHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SettingHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

