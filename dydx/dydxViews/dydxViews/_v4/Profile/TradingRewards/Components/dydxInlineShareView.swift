//
//  dydxInlineShareView.swift
//  dydxUI
//
//  Created by Michael Maguire on 2/23/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxInlineShareViewModel: PlatformViewModel {
    @Published public var shareAction: (() -> Void)?

    private let shareCta: AttributedString = {
        let localizedString = DataLocalizer.shared?.localize(path: "APP.GENERAL.SHARE_DYDX", params: nil) ?? ""
        let unhighlightedString = DataLocalizer.shared?.localize(path: "APP.GENERAL.SHARE", params: nil) ?? ""

        var attributedString = AttributedString(localizedString)
            .themeFont(fontType: .base, fontSize: .medium)

        attributedString = attributedString.themeColor(foreground: .textSecondary)
        if let unhighlightedStringRange = attributedString.range(of: unhighlightedString) {
            attributedString = attributedString.themeColor(foreground: .textTertiary, to: unhighlightedStringRange)
        }

        return attributedString
    }()

    public static var previewValue: dydxInlineShareViewModel = {
        let vm = dydxInlineShareViewModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(alignment: .center, spacing: 6) {
                    Text(self.shareCta)
                    PlatformIconViewModel(type: .asset(name: "icon_share", bundle: .dydxView),
                                          clip: .noClip,
                                          size: CGSize(width: 20, height: 20),
                                          templateColor: .textSecondary)
                    .createView(parentStyle: style)
                }
                    .onTapGesture { [weak self] in
                        self?.shareAction?()
                    }
            )
        }
    }
}

#Preview {
    Group {
        dydxInlineShareViewModel.previewValue
            .createView()
            .environmentObject(ThemeSettings.shared)
            .previewLayout(.sizeThatFits)
    }
}
