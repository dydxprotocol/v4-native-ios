//
//  dydxPortfolioHeaderView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioHeaderViewModel: PlatformViewModel {

    @Published public var depositAction: (() -> Void)?
    @Published public var onboardAction: (() -> Void)?
    @Published public var state: dydxPortfolioViewModel.State = .onboard

    public init(depositAction: (() -> Void)? = nil, onboardAction: (() -> Void)? = nil, state: dydxPortfolioViewModel.State = .onboard) {
        self.depositAction = depositAction
        self.onboardAction = onboardAction
        self.state = state
    }

    public init() {}

    public static var previewValue: dydxPortfolioHeaderViewModel {
        let vm = dydxPortfolioHeaderViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let title: String
            let icon: String
            let action: (() -> Void)?
            let backgroundColor: ThemeColor.SemanticColor
            let borderColor: ThemeColor.SemanticColor?
            switch self.state {
            case .onboard:
                title = DataLocalizer.localize(path: "APP.ONBOARDING.GET_STARTED")
                icon = "icon_wallet_connect"
                action = self.onboardAction
                backgroundColor = .colorPurple
                borderColor = nil
            case .onboardCompleted:
                title = DataLocalizer.localize(path: "APP.GENERAL.TRANSFER")
                icon = "icon_transfer"
                action = self.depositAction
                backgroundColor = .layer4
                borderColor = .layer6
            }

            return AnyView(
                HStack {
                    Text(title)
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)

                    let icon = PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                                     clip: .circle(background: backgroundColor, spacing: 24, borderColor: borderColor),
                                                     size: CGSize(width: 42, height: 42))
                    PlatformButtonViewModel(content: icon,
                                            type: .iconType,
                                            action: action ?? {})
                        .createView(parentStyle: style)
                }
                .frame(height: 48)
            )
        }
    }
}

#if DEBUG
struct dydxPortfolioHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
