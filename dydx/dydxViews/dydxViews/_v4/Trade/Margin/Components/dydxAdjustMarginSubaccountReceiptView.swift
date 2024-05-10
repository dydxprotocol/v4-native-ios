//
//  dydxAdjustMarginSubaccountReceiptView.swift
//  dydxUI
//
//  Created by Rui Huang on 09/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginSubaccountReceiptViewModel: PlatformViewModel {
    @Published public var freeCollateral: AmountChangeModel?
    @Published public var marginUsage: AmountChangeModel?

    public init() { }

    public static var previewValue: dydxAdjustMarginSubaccountReceiptViewModel {
        let vm = dydxAdjustMarginSubaccountReceiptViewModel()
        vm.freeCollateral = .previewValue
        vm.marginUsage = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 8) {
                self.createLine(title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_FREE_COLLATERAL"),
                                amount: self.freeCollateral,
                                parentStyle: style)
                self.createLine(title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_MARGIN_USAGE"),
                                amount: self.marginUsage,
                                parentStyle: style)
            }
                .padding(.top, 12)
                .padding(16)
                .themeColor(background: .layer2)
                .cornerRadius(8, corners: [.bottomLeft, .bottomRight])

            return AnyView(view)
        }
    }

    private func createLine(title: String, amount: AmountChangeModel?, parentStyle: ThemeStyle) -> some View {
        HStack {
            Text(title)
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Spacer()
            amount?.createView(parentStyle: parentStyle)
        }
    }
}

#if DEBUG
struct dydxAdjustMarginSubaccountReceiptView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginSubaccountReceiptViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginSubaccountReceiptView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginSubaccountReceiptViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
