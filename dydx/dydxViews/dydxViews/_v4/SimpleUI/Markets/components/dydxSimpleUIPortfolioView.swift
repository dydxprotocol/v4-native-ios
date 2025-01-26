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
            case .loggedOut: return DataLocalizer.localize(path: "APP.ONBOARDING.GET_STARTED")
            case .unknown: return ""
            }
        }

        var buttonIcon: String? {
            switch self {
            case .hasBalance: return nil
            case .walletConnected: return nil
            case .loggedOut: return "icon_wallet_connect"
            case .unknown: return nil
            }
        }
    }

    @Published public var buttonAction: (() -> Void)?
    @Published public var state: LoginState  = .unknown
    @Published public var sharedAccountViewModel: SharedAccountViewModel? = SharedAccountViewModel()
    @Published public var pnlAmount: SignedAmountViewModel?
    @Published public var pnlPercent: SignedAmountViewModel?
    @Published public var chart = dydxLineChartViewModel()

    @Published public var periodOption = dydxSimpleUIPortfolioPeriodViewModel.previewValue

    private var pnlColor: ThemeColor.SemanticColor {
        get {
            switch pnlPercent?.sign {
            case .plus: return ThemeSettings.positiveColor
            case .minus: return ThemeSettings.negativeColor
            default: return .layer6
            }
        }
    }

    public static var previewValue: dydxSimpleUIPortfolioViewModel {
        let vm = dydxSimpleUIPortfolioViewModel()
        vm.sharedAccountViewModel = SharedAccountViewModel.previewValue
        vm.pnlAmount = .previewValue
        vm.pnlPercent = .previewValue
        vm.state = .hasBalance
        vm.sharedAccountViewModel = .previewValue
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
                view = AnyView(createLoadingView(style: style))
            }

            return view
        }
    }

    private func createLoadingView(style: ThemeStyle) -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text("$1000.00")
                    .themeFont(fontType: .plus, fontSize: .custom(size: 32))
                    .themeColor(foreground: .textPrimary)

                HStack(alignment: .center, spacing: 8) {
                    SignedAmountViewModel.previewValue
                        .createView(parentStyle: style.themeFont(fontSize: .small))

                    SignedAmountViewModel.previewValue
                        .createView(parentStyle: style.themeFont(fontSize: .small))

                    dydxSimpleUIPortfolioPeriodViewModel.previewValue.createView(parentStyle: style)
                }
                .themeFont(fontSize: .small)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .leftAligned()

            Spacer()

            HStack(alignment: .center, spacing: 16) {
                HStack(alignment: .center, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
                        .themeColor(foreground: .textTertiary)
                    Text("$10000.0")
                        .themeColor(foreground: .textSecondary)
                }
                .themeFont(fontSize: .small)

                Spacer()

                HStack(alignment: .center, spacing: 8) {
                    let leverageIcon = LeverageRiskModel.previewValue
                    let leverageText = LeverageRiskModel(marginUsage: leverageIcon.marginUsage,
                                                         viewSize: leverageIcon.viewSize,
                                                         displayOption: .fullText)
                    leverageText.createView(parentStyle: style)
                    let leveragePercent = LeverageRiskModel(marginUsage: leverageIcon.marginUsage,
                                                            viewSize: leverageIcon.viewSize,
                                                            displayOption: .percent)
                    leveragePercent.createView(parentStyle: style.themeColor(foreground: .textTertiary))
                }
            }
            .frame(height: 32)
            .padding(.horizontal, 16)
        }
        .redacted(reason: .placeholder)
    }

    private func createPortfolioView(style: ThemeStyle) -> some View {
        ZStack {
            chart.createView(parentStyle: style)
                .opacity(0.6)
                .padding(.top, 78)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(sharedAccountViewModel?.equity ?? "-")
                        .themeFont(fontType: .plus, fontSize: .custom(size: 32))
                        .themeColor(foreground: .textPrimary)
                        .animation(.default)

                    HStack(alignment: .center, spacing: 8) {
                        pnlAmount?
                            .createView(parentStyle: style.themeFont(fontSize: .small))
                            .animation(.default)

                        pnlPercent?
                            .createView(parentStyle: style.themeFont(fontSize: .small))
                            .animation(.default)

                        periodOption.createView(parentStyle: style)
                    }
                    .themeFont(fontSize: .small)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .leftAligned()

                Spacer()

                HStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
                            .themeColor(foreground: .textTertiary)
                        Text(sharedAccountViewModel?.buyingPower ?? "-")
                            .themeColor(foreground: .textSecondary)
                            .animation(.default)
                    }
                    .themeFont(fontSize: .small)

                    Spacer()

                    HStack(alignment: .center, spacing: 8) {

                        if let leverageIcon = sharedAccountViewModel?.leverageIcon {
                            let leverageText = LeverageRiskModel(marginUsage: leverageIcon.marginUsage,
                                                                 viewSize: leverageIcon.viewSize,
                                                                 displayOption: .fullText)
                            leverageText.createView(parentStyle: style)
                            let leveragePercent = LeverageRiskModel(marginUsage: leverageIcon.marginUsage,
                                                                    viewSize: leverageIcon.viewSize,
                                                                    displayOption: .percent)
                            leveragePercent.createView(parentStyle: style.themeColor(foreground: .textTertiary))
                                .animation(.default)
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
            VStack(alignment: .leading, spacing: 0) {
                Text(dydxFormatter.shared.dollar(number: 0.0, digits: 2) ?? "")
                    .themeFont(fontType: .plus, fontSize: .custom(size: 32))
                    .themeColor(foreground: .textPrimary)

                let percent = dydxFormatter.shared.percent(number: 0.0, digits: 2)
                ColoredTextModel(text: percent, color: ThemeSettings.positiveColor)
                    .createView(parentStyle: style.themeFont(fontSize: .small))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .leftAligned()

            Spacer()

            Text(DataLocalizer.localize(path: "APP.GENERAL.NO_FUNDS"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)

            let buttonLabel = HStack {
                Text(
                    self.state.buttonText
                )
                .themeFont(fontType: .base, fontSize: .medium)

                if let iconName = self.state.buttonIcon {
                    PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                          size: CGSize(width: 20, height: 20),
                                          templateColor: .textPrimary)
                        .createView(parentStyle: style)
                }
            }

            PlatformButtonViewModel(content: buttonLabel.wrappedViewModel,
                                    type: .defaultType(pilledCorner: true)) { [weak self] in
                self?.buttonAction?()
            }
            .createView(parentStyle: style)
        }
        .background {
            Image(themedImageBaseName: "texture", bundle: .dydxView)
                .resizable()
                .scaledToFill()
                .opacity(0.2)
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
