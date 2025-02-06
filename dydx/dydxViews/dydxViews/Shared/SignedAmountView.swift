//
//  SignedAmountView.swift
//  dydxViews
//
//  Created by Michael Maguire on 2/13/24.
//

import PlatformUI
import dydxFormatter

public extension SignedAmountViewModel {
    convenience init(text: String? = nil, sign: PlatformUISign = .plus, coloringOption: ColoringOption, noneColor: ThemeColor.SemanticColor = .textSecondary) {
        self.init(text: text,
                  sign: sign,
                  coloringOption: coloringOption,
                  noneColor: noneColor,
                  positiveTextStyleKey: ThemeSettings.positiveTextStyleKey,
                  negativeTextStyleKey: ThemeSettings.negativeTextStyleKey)
    }

    convenience init(amount: Double?, displayType: DisplayType, coloringOption: ColoringOption, noneColor: ThemeColor.SemanticColor = .textSecondary, shouldDisplaySignForPositiveNumbers: Bool = false) {
        let formattedZero: String?
        let formattedText: String?
        let sign: PlatformUISign
        switch displayType {
        case .dollar:
            formattedText = dydxFormatter.shared.dollarVolume(number: amount?.magnitude, shouldDisplaySignForPositiveNumbers: shouldDisplaySignForPositiveNumbers)
            formattedZero = dydxFormatter.shared.dollarVolume(number: 0.0, shouldDisplaySignForPositiveNumbers: shouldDisplaySignForPositiveNumbers)
        case .percent:
            let digits = 2
            formattedText = dydxFormatter.shared.percent(number: amount?.magnitude, digits: digits, shouldDisplayPlusSignForPositiveNumbers: shouldDisplaySignForPositiveNumbers)
            formattedZero = dydxFormatter.shared.percent(number: 0.0, digits: digits, shouldDisplayPlusSignForPositiveNumbers: shouldDisplaySignForPositiveNumbers)
        }
        // special logic for when a value like -0.001 would render as "-$0.00" instead of "$0.00"
        if formattedText == formattedZero {
            sign = .none
        } else if (amount ?? 0) > 0 {
            sign = .plus
        } else {
            sign = .minus
        }
        self.init(text: formattedText,
                  sign: sign,
                  coloringOption: coloringOption,
                  noneColor: noneColor)
    }
}
