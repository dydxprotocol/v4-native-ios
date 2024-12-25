//
//  dydxSimpleUIPortfolioView.swift
//  dydxUI
//
//  Created by Rui Huang on 23/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxSimpleUIPortfolioViewModel: PlatformViewModel {
    public enum LoginState {
        case hasBalance
        case walletConnected
        case loggedOut
        case unknown

        var buttonText: String {
            switch self {
            case .hasBalance: return DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_FUNDS")
            case .walletConnected: return DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_FUNDS")
            case .loggedOut: return DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET")
            case .unknown: return ""
            }
        }
    }

    @Published public var buttonAction: (() -> Void)?
    @Published public var state: LoginState  = .unknown
    @Published public var sharedAccountViewModel: SharedAccountViewModel? = SharedAccountViewModel()
    @Published public var pnlAmount: String?
    @Published public var pnlPercent: SignedAmountViewModel?
    @Published public var chart = dydxLineChartViewModel()

    public static var previewValue: dydxSimpleUIPortfolioViewModel {
        let vm = dydxSimpleUIPortfolioViewModel()
        vm.sharedAccountViewModel = SharedAccountViewModel.previewValue
        vm.pnlAmount = "$100,000"
        vm.pnlPercent = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view: AnyView
            switch self.state {
            case .hasBalance:
                view = AnyView(createPortfolioView(style: style))
            case .walletConnected:
                view = AnyView(createLoggedOutView(style: style))
            case .loggedOut:
                view = AnyView(createLoggedOutView(style: style))
            case .unknown:
                view = AnyView(VStack {})
            }

            return view
        }
    }

    private func createPortfolioView(style: ThemeStyle) -> some View {
        ZStack {
            chart.createView(parentStyle: style)

            VStack(spacing: 16) {
                Spacer()

                HStack(alignment: .center, spacing: 16) {
                    Text(sharedAccountViewModel?.equity ?? "-")
                        .themeFont(fontType: .plus, fontSize: .largest)
                        .themeColor(foreground: .textPrimary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(pnlAmount ?? "-")
                            .themeColor(foreground: .textTertiary)
                        pnlPercent?.createView(parentStyle: style.themeFont(fontSize: .small))
                    }
                    .themeFont(fontSize: .small)
                }
                .frame(height: 48)
                .padding(.horizontal, 16)

                HStack(spacing: 16) {
                    HStack(alignment: .center) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
                            .themeColor(foreground: .textTertiary)
                        Spacer()
                        Text(sharedAccountViewModel?.buyingPower ?? "-")
                            .themeColor(foreground: .textSecondary)
                    }
                    .themeFont(fontSize: .small)

                    DividerModel().createView(parentStyle: style)

                    HStack(alignment: .center, spacing: 24) {
                        Text(DataLocalizer.localize(path: "APP.TRADE.RISK"))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)

                        if let leverageIcon = sharedAccountViewModel?.leverageIcon {
                            let leverageIcon = LeverageRiskModel(level: leverageIcon.level,
                                                                 viewSize: leverageIcon.viewSize,
                                                                 displayOption: .iconAndText)
                            leverageIcon.createView(parentStyle: style)
                        }
                    }
                }
                .frame(height: 32)
                .padding(.horizontal, 16)
            }
        }
    }

    private func createLoggedOutView(style: ThemeStyle) -> some View {
        VStack(spacing: 16) {

            Spacer()

            HStack {
                Text(dydxFormatter.shared.dollar(number: 0.0, digits: 2) ?? "")
                    .themeFont(fontType: .plus, fontSize: .largest)
                    .themeColor(foreground: .textPrimary)

                Spacer()

                let percent = dydxFormatter.shared.percent(number: 0.0, digits: 2)
                ColoredTextModel(text: percent, color: ThemeSettings.positiveColor)
                    .createView(parentStyle: style)
            }
            .frame(height: 80)

            Text(DataLocalizer.localize(path: "APP.GENERAL.NO_FUNDS"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)

            let buttonLabel = Text(
                self.state.buttonText
            ).themeFont(fontType: .base, fontSize: .medium)
            PlatformButtonViewModel(content: buttonLabel.wrappedViewModel) { [weak self] in
                self?.buttonAction?()
            }
            .createView(parentStyle: style)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct dydxSimpleUIPortfolioView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPortfolioViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIPortfolioView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPortfolioViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
