//
//  dydxPriceInputViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxPriceInputViewModel: PlatformTextInputViewModel {

    @Published public var hasInputError: Bool = false

    public init(title: String?, onEdited: ((String?) -> Void)? = nil) {
        super.init(
            label: title,
            labelAccessory: TokenTextViewModel(symbol: "USD", withBorder: true).createView(parentStyle: ThemeStyle.defaultStyle.themeFont(fontSize: .smallest)).wrappedInAnyView(),
            placeHolder: dydxFormatter.shared.dollar(number: 0.0, digits: 0),
            inputType: .decimalDigits,
            onEdited: onEdited
        )
    }

    public static var previewValue: dydxPriceInputViewModel = {
        let vm = dydxPriceInputViewModel(title: "TP Price")
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle.themeFont(fontType: .base, fontSize: .medium), styleKey: styleKey)
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { _  in
            return view
                .makeInput(withBorder: false)
                .border(borderWidth: 1, cornerRadius: 12, borderColor: self.hasInputError ? ThemeColor.SemanticColor.colorRed.color : .clear)
                .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxPriceInputViewModel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxPriceInputViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
