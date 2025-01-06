//
//  dydxTradeInputEditView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import SwiftUI
import PlatformUI
import Utilities
import Introspect

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

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        // need to find a better way to do this. Might not be sustainable.
                        // This is a bandaid workaround for keyboard. Might not be great on SE. Will not be good if we add more inputs
                        // if keyboardobserving is applied to more than one of the children, or applied to the scrollview, bizarre behavior ensues
                        ForEach(self.children?.prefix(while: { $0 !== self.children?.last }) ?? [], id: \.self.id) { child in
                            child.createView(parentStyle: style)
                        }
                        self.children?.last?.createView(parentStyle: style)
                            .keyboardObserving()
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
