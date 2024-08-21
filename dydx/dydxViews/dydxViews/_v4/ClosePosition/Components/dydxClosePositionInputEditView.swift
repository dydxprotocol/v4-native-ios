//
//  dydxClosePositionInputEditView.swift
//  dydxViews
//
//  Created by John Huang on 2/14/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxClosePositionInputEditViewModel: PlatformViewModel {
    @Published public var children: [PlatformValueInputViewModel]?

    public static var previewValue: dydxClosePositionInputEditViewModel {
        let vm = dydxClosePositionInputEditViewModel()
        vm.children = [
            dydxTradeInputSizeViewModel.previewValue,
            dydxClosePositionInputPercentViewModel.previewValue
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    ForEach(self.children ?? [], id: \.self.id) { child in
                        child.createView(parentStyle: style)
                    }
                    .animation(.default)

                    Spacer()
                }
                    .keyboardAccessory(background: .layer3, parentStyle: parentStyle)
            )
        }
    }
}

#if DEBUG
struct dydxClosePositionInputEditViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxClosePositionInputEditViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxClosePositionInputEditViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxClosePositionInputEditViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
