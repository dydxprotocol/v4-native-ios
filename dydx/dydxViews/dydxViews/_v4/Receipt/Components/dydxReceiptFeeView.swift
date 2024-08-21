//
//  dydxReceiptFeeView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/20/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxReceiptFeeViewModel: PlatformViewModel {
    public enum FeeFont {
        case number(String)
        case string(String)
    }

    @Published public var feeType: String?
    @Published public var fee: FeeFont?

    public init() { }

    public static var previewValue: dydxReceiptFeeViewModel {
        let vm = dydxReceiptFeeViewModel()
        vm.feeType = "Taker"
        vm.fee = .number("$0.00")
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    HStack(spacing: 4) {
                        Text(DataLocalizer.localize(path: "APP.TRADE.FEE"))
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textTertiary)
                            .lineLimit(1)
                        if let feeType = self.feeType {
                            Text(feeType)
                                .themeFont(fontType: .plus, fontSize: .small)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if let fee = self.fee {
                        switch fee {
                        case .number(let value):
                            Text(value)
                                .themeFont(fontType: .number, fontSize: .small)
                                .themeColor(foreground: .textPrimary)
                                .lineLimit(1)
                        case .string(let value):
                            Text(value)
                                .themeFont(fontType: .plus, fontSize: .small)
                                .themeColor(foreground: .textPrimary)
                                .lineLimit(1)
                        }
                    } else {
                        dydxReceiptEmptyView.emptyValue
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxReceiptFeeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptFeeViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxReceiptFeeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptFeeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
