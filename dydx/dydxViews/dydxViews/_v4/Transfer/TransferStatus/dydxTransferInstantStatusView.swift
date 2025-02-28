//
//  dydxTransferInstantStatusView.swift
//  dydxUI
//
//  Created by Rui Huang on 27/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxTransferInstantStatusViewModel: PlatformViewModel {
    public enum StatusIcon {
        case submitting, failed, success

        var title: String {
            switch self {
            case .submitting: return DataLocalizer.localize(path: "APP.TRADE.SUBMITTING")
            case .failed: return  DataLocalizer.localize(path: "APP.TRADE.FAILED")
            case .success: return  DataLocalizer.localize(path: "APP.TRADE.SUCCESS")
            }
        }
    }

    @Published public var title: String?
    @Published public var subtitle: String?

    @Published public var label: String?
    @Published public var amount: String?
    @Published public var token: String?
    @Published public var tokenIcon: URL?
    @Published public var chainIcon: URL?

    @Published public var status = StatusIcon.submitting
    @Published public var ctaButtonViewModel = dydxTradeStatusCtaButtonViewModel()
    @Published public var simpleUI: Bool = false {
        didSet {
            if simpleUI {
                ctaButtonViewModel.buttonType = PlatformButtonType.defaultType(
                    fillWidth: true,
                    pilledCorner: false,
                    minHeight: 60,
                    cornerRadius: 16)
            }
        }
    }

    public init() {}

    public static var previewValue: dydxTransferInstantStatusViewModel {
        let vm = dydxTransferInstantStatusViewModel()
        vm.title = "Deposit in progress"
        vm.subtitle = "Your deposit is currently being processed."
        vm.label = "Your deposit"
        vm.amount = "100.00"
        vm.token = "DAI"
        vm.chainIcon = URL(string: "https://v4.testnet.dydx.exchange/chains/ethereum.png")
        vm.tokenIcon = URL(string: "https://v4.testnet.dydx.exchange/currencies/usdc.png")
        vm.status = .submitting
        vm.ctaButtonViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)

            let view = VStack(spacing: 16) {
                Spacer()
                self.createCenterItems(style: style)
                Spacer()

                self.createBottomItems(style: style)
            }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, bottomPadding)
                .themeColor(background: .layer1)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createCenterItems(style: ThemeStyle) -> some View {
        VStack(alignment: .center, spacing: 16) {
            createIcon(style: style)
                .padding(.bottom, 16)
            Text(title ?? "")
                .themeFont(fontType: .plus, fontSize: .largest)
                .themeColor(foreground: .textPrimary)
                .multilineTextAlignment(.center)
            Text(subtitle ?? "")
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private func createIcon(style: ThemeStyle) -> some View {
        Group {
            switch status {
            case .submitting:
                IndeterminateCircularProgress(size: 72, color: ThemeColor.SemanticColor.colorPurple.color)
                    .withOutline()
            case .failed:
                PlatformIconViewModel(type: .system(name: "xmark"),
                                      clip: .circle(background: ThemeColor.SemanticColor.colorFadedRed, spacing: 42, borderColor: nil),
                                      size: CGSize(width: 72, height: 72),
                                      templateColor: ThemeColor.SemanticColor.colorRed)
                .createView(parentStyle: style)
            case .success:
                PlatformIconViewModel(type: .system(name: "checkmark"),
                                      clip: .circle(background: ThemeColor.SemanticColor.colorFadedGreen, spacing: 42, borderColor: nil),
                                      size: CGSize(width: 72, height: 72),
                                      templateColor: ThemeColor.SemanticColor.colorGreen)
                .createView(parentStyle: style)
            }
        }
    }

    private func createBottomItems(style: ThemeStyle) -> some View {
        VStack(spacing: 21) {
            HStack {
                HStack {
                    Text(label ?? "")
                        .themeColor(foreground: .textTertiary)
                }
                .themeFont(fontSize: .small)

                Spacer()

                if let amount = self.amount {
                    HStack(spacing: 8) {
                        ZStack {
                            PlatformIconViewModel(type: .url(url: self.tokenIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 24, height: 24))
                                .createView(parentStyle: style)

                            PlatformIconViewModel(type: .url(url: self.chainIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 12, height: 12))
                                .createView(parentStyle: style)
                                .rightAligned()
                                .bottomAligned()
                        }
                        .frame(width: 24, height: 24)

                        Text(amount)
                        Text(token ?? "")
                            .themeColor(foreground: .textTertiary)
                    }
                    .themeFont(fontSize: .small)
                }
            }
            ctaButtonViewModel.createView(parentStyle: style)
        }
    }
}

#if DEBUG
struct dydxTransferInstantStatusView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferInstantStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferInstantStatusView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferInstantStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
