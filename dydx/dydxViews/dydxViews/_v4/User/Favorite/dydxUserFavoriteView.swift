//
//  dydxUserFavoriteView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxUserFavoriteViewModel: PlatformViewModel {
    @Published public var isFavorited: Bool = false
    @Published public var size: CGSize
    @Published public var onTapped: (() -> Void)?
    @Published public var handleTap: Bool = true

    public init(size: CGSize = .init(width: 16, height: 16)) {
        self.size = size
    }

    public convenience init(isFavorited: Bool = false,
                            size: CGSize = .init(width: 16, height: 16),
                            onTapped: (() -> Void)? = nil) {
        self.init()
        self.isFavorited = isFavorited
        self.size = size
        self.onTapped = onTapped
    }

    public static var previewValue: dydxUserFavoriteViewModel {
        let vm = dydxUserFavoriteViewModel()
        vm.isFavorited = false
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let icon = self.isFavorited ? "action_like_small" : "action_dislike_small"
            let content = PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                                size: self.size)

            if self.handleTap {
                return AnyView(
                    Button { [weak self] in
                        self?.onTapped?()
                    } label: {
                        content.createView(parentStyle: style, styleKey: styleKey)
                    }
                    .tint(ThemeColor.SemanticColor.layer2.color)
                )
            } else {
                return AnyView(
                    content.createView(parentStyle: style, styleKey: styleKey)
                        .tint(ThemeColor.SemanticColor.layer2.color)
                )
            }
        }
    }
}

#if DEBUG
struct dydxUserFavoriteView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxUserFavoriteViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxUserFavoriteView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxUserFavoriteViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
