//
//  PlaceholderView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/13/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class PlaceholderViewModel: PlatformViewModel {
    @Published public var text: String?

    public init(text: String? = nil) {
        self.text = text
    }

    public static var previewValue: PlaceholderViewModel {
        let vm = PlaceholderViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(self.text ?? "")
               .themeFont(fontSize: .small)
               .themeColor(foreground: .textTertiary)
               .centerAligned()
               .frame(maxWidth: .infinity)
               .padding(.vertical, 8)
               .wrappedViewModel

            return AnyView(
                 PlatformTableViewCellViewModel(main: main)
                    .createView(parentStyle: style)
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .themeColor(background: .layer4)
                    .cornerRadius(16)
            )
        }
    }
}

#if DEBUG
struct PlaceHolderView_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return PlaceholderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct PlaceHolderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return PlaceholderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
