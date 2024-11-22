//
//  dydxAdjustMarginReceiptViewModel.swift
//  dydxUI
//
//  Created by Mike Maguire on 06/11/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginReceiptViewModel: PlatformViewModel {

    @Published public var padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    @Published public var receiptChangeItems: [dydxReceiptChangeItemView] = []

    public init() { }

    public static var previewValue: dydxAdjustMarginReceiptViewModel {
        let vm = dydxAdjustMarginReceiptViewModel()
        vm.receiptChangeItems = [.previewValue, .previewValue]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 8) {
                ForEach(self.receiptChangeItems, id: \.id) { item in
                    item.createView(parentStyle: style)
                }
            }
                .padding(padding)
                .themeColor(background: .layer2)
                .clipShape(.rect(cornerRadius: 10))

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxAdjustMarginPositionReceiptView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginReceiptViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginPositionReceiptView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginReceiptViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
