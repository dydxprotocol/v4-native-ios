//
//  SampleThemeLabel.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/9/22.
//

import SwiftUI

struct SampleThemeLabel: View {
    init(text: String,
                textColor: ThemeColor.SemanticColor = .textTertiary,
                fontType: ThemeFont.FontType = .text,
                fontSize: ThemeFont.FontSize = .largest) {
        self.text = text
        self.textColor = textColor
        self.fontType = fontType
        self.fontSize = fontSize
    }

    let text: String
    let textColor: ThemeColor.SemanticColor
    let fontType: ThemeFont.FontType
    let fontSize: ThemeFont.FontSize
    
    var body: some View {
        Text(text)
            .themeColor(foreground: textColor)
            .themeFont(fontType: fontType, fontSize: fontSize)
    
    }
}

#if DEBUG
struct SampleThemeLabel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings()

    static var previews: some View {
        ZStack {
            themeSettings.themeConfig.themeColor.color(of: .layer0)
            VStack {
                Spacer()
                Group {
                    SampleThemeLabel(text: "labelText", fontType: .bold)
                    SampleThemeLabel(text: "labelText", fontType: .text)
                    SampleThemeLabel(text: "labelText", fontType: .number)
                }
                Spacer()
                Group {
                    SampleThemeLabel(text: "labelText", fontSize: .largest)
                    SampleThemeLabel(text: "labelText", fontSize: .larger)
                    SampleThemeLabel(text: "labelText", fontSize: .large)
                }
                Spacer()
                Group {
                    SampleThemeLabel(text: "labelText", textColor: .textTertiary)
                    SampleThemeLabel(text: "labelText", textColor: .textSecondary)
                    SampleThemeLabel(text: "labelText", textColor: .textPrimary)
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .environmentObject(themeSettings)
    }
}
#endif
