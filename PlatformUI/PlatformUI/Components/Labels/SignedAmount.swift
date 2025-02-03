//
//  SignedAmount.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/24/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class SignedAmountViewModel: PlatformViewModel, Hashable {
    public enum ColoringOption {
        case signOnly
        case textOnly
        case allText
    }

    public enum DisplayType {
        case dollar
        case percent
    }

    @Published public var text: String?
    @Published public var sign: PlatformUISign
    @Published public var coloringOption: ColoringOption
    @Published public var positiveTextStyleKey: String
    @Published public var negativeTextStyleKey: String
    @Published public var noneColor: ThemeColor.SemanticColor
    
    public init(text: String? = nil,
                sign: PlatformUISign = .plus,
                coloringOption: ColoringOption,
                noneColor: ThemeColor.SemanticColor = .textSecondary,
                positiveTextStyleKey: String,
                negativeTextStyleKey: String) {
        self.text = text
        self.sign = sign
        self.coloringOption = coloringOption
        self.positiveTextStyleKey = positiveTextStyleKey
        self.negativeTextStyleKey = negativeTextStyleKey
        self.noneColor = noneColor
    }

    public static func == (lhs: SignedAmountViewModel, rhs: SignedAmountViewModel) -> Bool {
        lhs.text == rhs.text &&
        lhs.sign == rhs.sign &&
        lhs.coloringOption == rhs.coloringOption
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(sign)
        hasher.combine(coloringOption)
    }

    public static var previewValue = SignedAmountViewModel(text: "2.02", sign: .plus, coloringOption: .allText, positiveTextStyleKey: "signed-plus", negativeTextStyleKey: "signed-minus")

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(alignment: .center, spacing: 2) {
                    if let text = self.text {
                        switch self.coloringOption {
                        case .signOnly, .allText:
                            switch self.sign {
                            case .plus:
                                Text("+")
                                    .themeStyle(styleKey: self.positiveTextStyleKey, parentStyle: style)
                            case .minus:
                                Text("-")
                                    .themeStyle(styleKey: self.negativeTextStyleKey, parentStyle: style)

                            case .none:
                                Text("")
                            }
                        case .textOnly:
                            PlatformView.nilView
                        }

                        switch self.coloringOption {
                        case .signOnly:
                            Text(text)
                        case .allText, .textOnly:
                            switch self.sign {
                            case .plus:
                                Text(text)
                                    .themeStyle(styleKey: self.positiveTextStyleKey, parentStyle: style)
                            case .minus:
                                Text(text)
                                    .themeStyle(styleKey: self.negativeTextStyleKey, parentStyle: style)
                            case .none:
                                Text(text)
                                    .themeColor(foreground: self.noneColor)
                            }
                        }
                    } else {
                        PlatformView.nilView
                    }
                }
             //   .minimumScaleFactor(0.5)
            )
        }
    }
}

#if DEBUG
struct SignedAmount_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            SignedAmountViewModel(text: "$2.00", sign: .plus, coloringOption: .allText, positiveTextStyleKey: "signed-plus", negativeTextStyleKey: "signed-minus").createView()
                .previewLayout(.sizeThatFits)

            SignedAmountViewModel(text: "$2.00", sign: .minus, coloringOption: .allText, positiveTextStyleKey: "signed-plus", negativeTextStyleKey: "signed-minus").createView()
                .previewLayout(.sizeThatFits)

            SignedAmountViewModel(text: "$2.00", sign: .plus, coloringOption: .allText, positiveTextStyleKey: "signed-plus", negativeTextStyleKey: "signed-minus").createView()
                .previewLayout(.sizeThatFits)

            SignedAmountViewModel(text: "$2.00", sign: .minus, coloringOption: .allText, positiveTextStyleKey: "signed-plus", negativeTextStyleKey: "signed-minus").createView()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
