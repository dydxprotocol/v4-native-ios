//
//  dydxTradeInputCtaButtonView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/14/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradeInputCtaButtonViewModel: PlatformViewModel {
    public enum State {
        case enabled(String? = nil)
        case disabled(String? = nil)
        case thinking
    }

    @Published public var ctaAction: (() -> Void)?
    @Published public var ctaButtonState: State = .disabled()

    public init() { }

    public static var previewValue: dydxTradeInputCtaButtonViewModel {
        let vm = dydxTradeInputCtaButtonViewModel()
        vm.ctaButtonState = .enabled("OK")
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
        let state: PlatformButtonState
        switch ctaButtonState {
        case .enabled(let title):
            buttonTitle = title ?? DataLocalizer.localize(path: "APP.TRADE.PREVIEW")
            state = .primary
        case .disabled(let title):
            buttonTitle = title ?? DataLocalizer.localize(path: "ERRORS.TRADE_BOX_TITLE.MISSING_TRADE_SIZE")
            state = .disabled
        case .thinking:
            buttonTitle = DataLocalizer.localize(path: "APP.V4.CALCULATING")
            state = .disabled
        }

        let buttonContent =
            Text(buttonTitle)
                .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent,
                                       state: state) { [weak self] in
            PlatformView.hideKeyboard()
            self?.ctaAction?()
        }
           .createView(parentStyle: style)
           .animation(.easeInOut(duration: 0.1))
    }
}

#if DEBUG
struct dydxTradeInputCtaButtonView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputCtaButtonViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputCtaButtonView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputCtaButtonViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
