//
//  dydxTradeStatusView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/26/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradeStatusViewModel: PlatformViewModel {
    @Published public var logoViewModel = dydxTradeStatusLogoViewModel()
    @Published public var orderViewModel = SharedFillViewModel()
    @Published public var ctaButtonViewModel = dydxTradeStatusCtaButtonViewModel()

    public init() { }

    public static var previewValue: dydxTradeStatusViewModel {
        let vm = dydxTradeStatusViewModel()
        vm.logoViewModel = .previewValue
        vm.orderViewModel = .previewValue
        vm.ctaButtonViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = AnyView(
                VStack {
                    self.logoViewModel.createView(parentStyle: style)
                        .padding(.top, 32)
                        .padding(.bottom, 32)

                    DividerModel().createView(parentStyle: style)

                    self.orderViewModel.createView(parentStyle: style)
                        .padding(.vertical, 8)

                    DividerModel().createView(parentStyle: style)

                    self.ctaButtonViewModel.createView(parentStyle: style)
                        .padding(.top, 16)
                }
            )
                .padding([.leading, .trailing])
                .padding(.bottom, self.safeAreaInsets?.bottom)
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxTradeStatusView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeStatusViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeStatusView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeStatusViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
