//
//  FieldInputSwitchView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/29/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import JedioKit

public class FieldInputSwitchViewModel: FieldInputBaseViewModel {
    public static var previewValue: FieldInputSwitchViewModel {
        let vm = FieldInputSwitchViewModel()
        vm.title = "title"
        vm.subtitle = "subititle"
        vm.text = "text"
        return vm
    }
    
    public lazy var inputBinding = Binding<Bool> {
        return self.input?.checked ?? false
    } set: { newValue in
        self.input?.checked = newValue
        self.valueChanged?(newValue)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(self.title ?? "")
                            .themeFont(fontSize: .medium)
                        if let subtitle = self.subtitle {
                            Text(subtitle)
                                .themeColor(foreground: .textTertiary)
                                .themeFont(fontSize: .small)
                        }
                    }
                    Spacer()
                    Toggle("", isOn: self.inputBinding)
                }
                .padding()
            )
        }
    }
}

#if DEBUG
struct FieldInputSwitchView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return FieldInputSwitchViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct FieldInputSwitchView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return FieldInputSwitchViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

