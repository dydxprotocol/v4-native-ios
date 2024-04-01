//
//  dydxTakeProfitStopLossViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 4/1/24.
//

import PlatformUI
import SwiftUI
import Utilities
import Introspect

public class dydxTakeProfitStopLossViewModel: PlatformViewModel {

    public init() {}

    public static var previewValue: dydxTakeProfitStopLossViewModel {
        let vm = dydxTakeProfitStopLossViewModel()
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(localizerPathKey: "APP.TRIGGERS_MODAL.PRICE_TRIGGERS")
                        .themeFont(fontType: .plus, fontSize: .larger)
                        .themeColor(foreground: .textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(localizerPathKey: "APP.TRIGGERS_MODAL.PRICE_TRIGGERS_DESCRIPTION")
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                HStack(alignment: .center, spacing: 8) {
                    Text(localizerPathKey: "APP.GENERAL.ADVANCED")
                    Rectangle()
                        .frame(height: 1)
                        .themeFont(fontType: .base, fontSize: .smallest)
                        .themeColor(background: .textTertiary)
                }
            }
            .padding(.top, 32)
            .padding([.leading, .trailing])
            .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
            .themeColor(background: .layer3)
            .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#Preview {
    dydxTakeProfitStopLossViewModel.previewValue
        .createView()
        .previewLayout(.fixed(width: 375, height: 667))
        .previewDisplayName("dydxTakeProfitStopLossViewModel")
}
