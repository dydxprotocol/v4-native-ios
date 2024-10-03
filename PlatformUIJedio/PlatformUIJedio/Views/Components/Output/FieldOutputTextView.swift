//
//  FieldOutputTextView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/21/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class FieldOutputTextViewModel: FieldOutputBaseViewModel {
    public static var previewValue: FieldOutputTextViewModel {
        let vm = FieldOutputTextViewModel()
        vm.title = "title"
        vm.subtitle = "subititle"
        vm.text = "text"
        vm.subtext = "subtext"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main =
                VStack(alignment: .leading) {
                    Text(self.title ?? "")
                    if let subtitle = self.subtitle {
                        Text(subtitle)
                            .themeFont(fontSize: .small)
                    }
                }
                .padding(.vertical, 4)

            let trailing =
                HStack {
                    VStack(alignment: .trailing) {
                        Text(self.text ?? "")
                            .themeFont(fontSize: .medium)
                        if let subtext = self.subtext {
                            Text(subtext)
                                .themeFont(fontSize: .small)
                        }
                    }
                    if self.link != nil {
                        PlatformIconViewModel(type: .system(name: "chevron.right"),
                                              size: CGSize(width: 16, height: 16),
                                              templateColor: .textTertiary)
                            .createView(parentStyle: style)
                    }
                }
                .themeColor(foreground: .textTertiary)

            return AnyView(
                PlatformTableViewCellViewModel(main: main.wrappedViewModel,
                                               trailing: trailing.wrappedViewModel)
                    .createView(parentStyle: style)
                    .onTapGesture { [weak self] in
                        self?.onTapAction?()
                    }
            )
        }
    }
}

#if DEBUG
struct FieldOutputTextView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return FieldOutputTextViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct FieldOutputTextView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return FieldOutputTextViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
