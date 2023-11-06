//
//  AmountText.swift
//  dydxViews
//
//  Created by Rui Huang on 10/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class AmountTextModel: PlatformViewModel, Equatable {
    @Published public var amount: NSNumber?
    @Published public var tickSize: NSNumber?
    @Published public var requiresPositive: Bool = false

    public init(amount: NSNumber? = nil, tickSize: NSNumber? = nil, requiresPositive: Bool = false) {
        self.amount = amount
        self.tickSize = tickSize
        self.requiresPositive = requiresPositive
    }

    public static var previewValue: AmountTextModel {
        let vm = AmountTextModel()
        vm.amount = NSNumber(value: 1234)
        vm.tickSize = NSNumber(value: 0.01)
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            var amount = self?.amount?.filter(filter: self?.requiresPositive == true ? .notNegative : nil)
            let amountText = dydxFormatter.shared.dollar(number: amount, size: self?.tickSize?.stringValue)
            return AnyView(
                Text(amountText ?? "-")
                    .themeFont(fontType: .number, fontSize: .small)
            )
        }
    }

    public static func == (lhs: AmountTextModel, rhs: AmountTextModel) -> Bool {
        lhs.amount == rhs.amount &&
        lhs.tickSize == rhs.tickSize
    }
}

#if DEBUG
struct AmountText_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return AmountTextModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct AmountText_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return AmountTextModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
