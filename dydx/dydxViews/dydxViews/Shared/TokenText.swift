//
//  TokenText.swift
//  dydxViews
//
//  Created by Rui Huang on 8/25/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class TokenTextViewModel: PlatformViewModel, Hashable {
    @Published public var symbol: String = "---"

    public init(symbol: String = "---") {
        self.symbol = symbol
    }

    public static var previewValue = TokenTextViewModel(symbol: "ETH")

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Group {
                    Text(self.symbol)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.vertical, 1)
                        .padding(.horizontal, 3)
                }
                .themeColor(background: .layer6)
                .cornerRadius(4)
            )
        }
    }

    public static func == (lhs: TokenTextViewModel, rhs: TokenTextViewModel) -> Bool {
        lhs.symbol == rhs.symbol
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

#if DEBUG
struct TokenText_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return TokenTextViewModel.previewValue
            .createView()
            .previewLayout(.sizeThatFits)
    }
}

struct TokenText_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return TokenTextViewModel.previewValue
            .createView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
