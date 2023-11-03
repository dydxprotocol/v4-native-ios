//
//  dydxMarketOrderbookView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/25/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketOrderbookViewModel: dydxOrderbookViewModel {
    @Published public var group: dydxOrderbookGroupViewModel? = dydxOrderbookGroupViewModel()

    public override init(bodyBuilder: ((ThemeStyle) -> AnyView)? = nil) {
        super.init(bodyBuilder: bodyBuilder)
        self.spread = dydxMarketOrderbookSpreadViewModel()
        self.bids?.displayStyle = .sideBySide
        self.asks?.displayStyle = .sideBySide
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading, spacing: 0) {
                    DividerModel().createView(parentStyle: style)

                    HStack {
                        self.spread?.createView(parentStyle: style)
                        Spacer()
                        self.group?.createView(parentStyle: style)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 40)

                    DividerModel().createView(parentStyle: style)

                    HStack(spacing: 0) {
                        self.asks?.createView(parentStyle: style)
                            .frame(minHeight: 0, maxHeight: .infinity)
                        self.bids?.createView(parentStyle: style)
                            .frame(minHeight: 0, maxHeight: .infinity)
                    }
                    .padding(.all, 8)

                    DividerModel().createView(parentStyle: style)
                }
                    .animation(.default)
            )
        }
    }
}

#if DEBUG
struct dydxMarketOrderbookView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketOrderbookViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketOrderbookView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketOrderbookViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
