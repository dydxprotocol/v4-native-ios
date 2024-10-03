//
//  SampleStyleLabel.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/23/22.
//

import SwiftUI

struct SampleStyleLabel: View, PlatformUIViewProtocol {
    @ObservedObject var themeSettings = ThemeSettings.shared

    var parentStyle: ThemeStyle = ThemeStyle.defaultStyle

    var styleKey: String? = "title-style"

    var body: some View {
        HStack {
            Text("Title")
                .themeStyle(style: style)
                .environmentObject(themeSettings)
            SampleSubtitleStyleLabel(parentStyle: style)
        }
    }
}

struct SampleSubtitleStyleLabel: View, PlatformUIViewProtocol {
    @ObservedObject var themeSettings = ThemeSettings.shared

    var parentStyle: ThemeStyle = ThemeStyle.defaultStyle
    var styleKey: String? = "subtitle-style"

    var body: some View {
        Text("Subtitle")
            .themeStyle(style: style)
            .environmentObject(themeSettings)
    }
}

#if DEBUG
struct SampleStyleLabel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ZStack {
             VStack {
                 Spacer()
                 SampleStyleLabel()
                 Spacer()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .environmentObject(themeSettings)
    }
}
#endif
