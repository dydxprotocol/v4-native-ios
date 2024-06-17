//
//  dydxReceiptChangeItemView.swift
//  dydxUI
//
//  Created by Mike Maguire on 6/11/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxReceiptChangeItemView: PlatformViewModel {
    @Published public var title: String
    @Published public var value: AmountChangeModel

    public init(title: String, value: AmountChangeModel) {
        self.title = title
        self.value = value
    }

    public static var previewValue: dydxReceiptChangeItemView {
        let vm = dydxReceiptChangeItemView(title: "Title", value: .previewValue)
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(alignment: .top) {
                    Text(self.title)
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .lineLimit(2)
                    Spacer()
                    self.value.createView(parentStyle: parentStyle)
                }
            )
        }
    }
}

#if DEBUG
struct dydxReceiptChangeItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptChangeItemView.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxReceiptChangeItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptChangeItemView.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
