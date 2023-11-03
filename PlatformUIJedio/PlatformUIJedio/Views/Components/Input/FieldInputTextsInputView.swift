//
//  FieldInputTextsInputView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/29/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class FieldInputTextsInputViewModel: FieldInputBaseViewModel {
     private lazy var inputBinding = Binding<String>(
        get: {
            self.input?.value as? String ?? ""
        },
        set: {
            self.input?.value = $0
        }
    )
    
    public static var previewValue: FieldInputTextsInputViewModel {
        let vm = FieldInputTextsInputViewModel()
        return vm
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading) {
                    HStack {
                        Text(self.title ?? "")
                            .themeFont(fontSize: .medium)
                        Spacer()
                        if let subtitle = self.subtitle {
                            Text(subtitle)
                                .themeColor(foreground: .textTertiary)
                                .themeFont(fontSize: .small)
                        }
                    }
                    Spacer()
                    PlatformInputModel(value: self.inputBinding,
                                       currentValue: self.input?.value as? String,
                                       keyboardType: .default)
                    .createView(parentStyle: style)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .themeColor(background: .layer0)
                }
                .padding()
            )
        }
    }
}

#if DEBUG
struct FieldInputTextsInputView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return FieldInputTextsInputViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct FieldInputTextsInputView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return FieldInputTextsInputViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

