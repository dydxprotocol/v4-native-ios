//
//  AmountChange.swift
//  dydxViews
//
//  Created by Rui Huang on 10/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class AmountChangeModel: BeforeArrowAfterModel<AmountTextModel> {

    public convenience init(before: AmountTextModel?, after: AmountTextModel?, increasingIsPositiveDirection: Bool = true) {
        self.init()

        self.before = before
        self.after = after

        changeDirection = { [weak self] in
            guard let beforeAmount = self?.before?.amount, let afterAmount = self?.after?.amount else {
                return .orderedSame
            }
            if increasingIsPositiveDirection {
                return beforeAmount.compare(afterAmount)
            } else {
                return afterAmount.compare(beforeAmount)
            }
        }
    }

    public required init(unit: AmountTextModel.Unit = .dollar) {
        super.init()

        before = AmountTextModel(unit: unit)
        after = AmountTextModel(unit: unit)

        changeDirection = { [weak self] in
            guard let beforeAmount = self?.before?.amount, let afterAmount = self?.after?.amount else {
                return .orderedSame
            }
            return beforeAmount.compare(afterAmount)
        }
    }

    public static var previewValue: AmountChangeModel = {
        let vm = AmountChangeModel()
        vm.before = .previewValue
        vm.after = .previewValue
        vm.before?.amount = NSNumber(value: 1000)
        return vm
    }()
}

#if DEBUG
struct AmountChange_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return AmountChangeModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct AmountChange_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return AmountChangeModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
