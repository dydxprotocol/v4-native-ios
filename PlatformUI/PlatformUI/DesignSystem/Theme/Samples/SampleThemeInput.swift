//
//  SampleThemeInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/9/22.
//

import SwiftUI

struct SampleThemeInput: View {
    init(value: Binding<String>,
                prompt: String? = nil,
                fontType: ThemeFont.FontType = .number,
                fontSize: ThemeFont.FontSize = .larger) {
        self.value = value
        self.prompt = prompt
        self.fontType = fontType
        self.fontSize = fontSize
    }

    let value: Binding<String>
    let prompt: String?
    let fontType: ThemeFont.FontType
    let fontSize: ThemeFont.FontSize
    
    var body: some View {
        return TextField(prompt ?? "", text: value)
            .themeColor(foreground: .textSecondary)
            .themeColor(background: .layer1)
            .themeFont(fontType: fontType, fontSize: fontSize)
    }
}

#if DEBUG
struct SampleThemeInput_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings()
    @State static var textValue = "input value"
    @State static var textValueEmpty = ""
    static var previews: some View {
        ZStack {
            themeSettings.themeConfig.themeColor.color(of: .layer0) 
            VStack {
                Spacer()
                Group {
                    SampleThemeInput(value: $textValue)
                    SampleThemeInput(value: $textValueEmpty, prompt: "Enter Text")
                }.padding()
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .environmentObject(themeSettings)
    }
}
#endif
