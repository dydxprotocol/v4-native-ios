//
//  dydxReceiptLoadingItemView.swift
//  dydxUI
//
//  Created by Mike Maguire on 6/11/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxReceiptLoadingItemView: PlatformViewModel {
    @Published public var title: String

    public init(title: String) {
        self.title = title
    }

    public static var previewValue: dydxReceiptChangeItemView {
        let vm = dydxReceiptChangeItemView(title: "Title")
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            let textFontSize = ThemeFont.FontSize.small
            return AnyView(
                HStack(alignment: .top) {
                    Text(self.title)
                        .themeFont(fontSize: textFontSize)
                        .themeColor(foreground: .textTertiary)
                        .lineLimit(2)
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(ThemeColor.SemanticColor.textSecondary.color)
                        .frame(height: ThemeSettings.shared.themeConfig.themeFont.uiFont(of: .base, fontSize: textFontSize)?.lineHeight)
                }
            )
        }
    }
}
