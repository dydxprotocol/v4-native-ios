//
//  dydxTradeStatusCtaButtonView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/27/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradeStatusCtaButtonViewModel: PlatformViewModel {
    public enum State {
        case cancel
        case done
        case tryAgain
    }

    @Published public var ctaAction: (() -> Void)?
    @Published public var ctaButtonState: State = .cancel

    public init() { }

    public static var previewValue: dydxTradeStatusCtaButtonViewModel {
        let vm = dydxTradeStatusCtaButtonViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                self.createCtaButton(parentStyle: style)
            )
        }
    }

    private func createCtaButton(parentStyle style: ThemeStyle) -> some View {
        let buttonTitle: String
        let buttonState: PlatformButtonState
        switch ctaButtonState {
        case .cancel:
            buttonTitle = DataLocalizer.localize(path: "APP.TRADE.CANCEL_ORDER")
            buttonState = .destructive
        case .done:
            buttonTitle = DataLocalizer.localize(path: "APP.GENERAL.DONE")
            buttonState = .primary
        case .tryAgain:
            buttonTitle = DataLocalizer.localize(path: "APP.ONBOARDING.TRY_AGAIN")
            buttonState = .primary
        }

        let buttonContent = Text(buttonTitle)
                .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent,
                                       state: buttonState) { [weak self] in
            self?.ctaAction?()
        }
           .createView(parentStyle: style)
           .animation(.easeInOut(duration: 0.1))
    }
}

#if DEBUG
struct dydxTradeStatusCtaButtonView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeStatusCtaButtonViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeStatusCtaButtonView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeStatusCtaButtonViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
