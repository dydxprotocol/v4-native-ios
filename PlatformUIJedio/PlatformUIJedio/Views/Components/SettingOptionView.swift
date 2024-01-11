//
//  SettingOptionView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/20/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SettingOptionViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var isSelected = false
    @Published public var onTapAction: (() -> Void)?

    public init() { }

    public static var previewValue: SettingOptionViewModel {
        let vm = SettingOptionViewModel()
        vm.text = "Test String"
        vm.isSelected = true
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(self.text ?? "")
                .padding(.vertical, 4)
            let trailing: PlatformViewModel
            if self.isSelected {
                trailing =  PlatformIconViewModel(type: .system(name: "checkmark"), size: CGSize(width: 16, height: 16))
            } else {
                trailing = PlatformView.nilViewModel
            }
            return AnyView(
                PlatformTableViewCellViewModel(main: main.wrappedViewModel,
                                               trailing: trailing)
                            .createView(parentStyle: parentStyle)
                            .onTapGesture { [weak self] in
                                self?.onTapAction?()
                            }
            )
        }
    }
}

#if DEBUG
struct SettingOptionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SettingOptionViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SettingOptionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SettingOptionViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
