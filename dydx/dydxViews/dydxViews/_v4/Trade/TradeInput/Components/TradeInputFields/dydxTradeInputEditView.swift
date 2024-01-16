//
//  dydxTradeInputEditView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import dydxFormatter
import Introspect
import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputEditViewModel: PlatformViewModel {
    @Published public var children: [PlatformValueInputViewModel]?
    @Published public var onScrollViewCreated: ((UIScrollView) -> Void)?

    public static var previewValue: dydxTradeInputEditViewModel {
        let vm = dydxTradeInputEditViewModel()
        vm.children = [
            dydxTradeInputSizeViewModel.previewValue,
            dydxTradeInputLeverageViewModel.previewValue,
            dydxTradeInputTimeInForceViewModel.previewValue,
            dydxTradeInputGoodTilViewModel.previewValue,
            dydxTradeInputReduceOnlyViewModel.previewValue
        ]
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(self.children ?? [], id: \.self.id) { child in
                            child.createView(parentStyle: style)
                        }
                    }
                    .introspectScrollView { [weak self] scrollView in
                        self?.onScrollViewCreated?(scrollView)
                    }
                }
                .keyboardAccessory(background: .layer3, parentStyle: parentStyle)
            )
        }
    }
}

#if DEBUG
    struct dydxTradeInputEditView_Previews_Dark: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyDarkTheme()
            ThemeSettings.applyStyles()
            return dydxTradeInputEditViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }

    struct dydxTradeInputEditView_Previews_Light: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyLightTheme()
            ThemeSettings.applyStyles()
            return dydxTradeInputEditViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
