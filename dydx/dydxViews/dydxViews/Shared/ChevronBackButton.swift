//
//  ChevronBackButton.swift
//  dydxUI
//
//  Created by Rui Huang on 4/10/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class ChevronBackButtonModel: PlatformViewModel {
    @Published public var onBackButtonTap: (() -> Void)?

    public init() { }

    public init(onBackButtonTap: (() -> Void)? = nil) {
        self.onBackButtonTap = onBackButtonTap
    }

    public static var previewValue: ChevronBackButtonModel {
        let vm = ChevronBackButtonModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                PlatformButtonViewModel(content: PlatformIconViewModel(type: .asset(name: "icon_chevron_back", bundle: Bundle.dydxView),
                                                                       size: CGSize(width: 16, height: 16),
                                                                       templateColor: ThemeColor.SemanticColor.textTertiary),
                                        type: .iconType,
                                        action: self.onBackButtonTap ?? {})
                    .createView(parentStyle: style)
            )
        }
    }
}

#if DEBUG
struct ChevronBackButton_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return ChevronBackButtonModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct ChevronBackButton_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return ChevronBackButtonModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
