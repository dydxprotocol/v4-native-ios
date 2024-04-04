//
//  dydxGainLossInputViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxGainLossInputViewModel: PlatformTextInputViewModel {
    public init(triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType, onEdited: ((String?) -> Void)? = nil) {
        super.init(
            label: DataLocalizer.shared?.localize(path: triggerType.gainLossInputTitleLocalizerPath, params: nil),
            placeHolder: dydxFormatter.shared.dollar(number: 0.0, digits: 0),
            // TODO: replace when percentage input is in abacus
//            valueAccessoryView: accessoryView,
            inputType: .decimalDigits,
            onEdited: onEdited
        )
    }

    public static var previewValue: dydxGainLossInputViewModel = {
        let vm = dydxGainLossInputViewModel(triggerType: .takeProfit)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            return view
                .makeInput()
                .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxGainLossInputViewModel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxGainLossInputViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
