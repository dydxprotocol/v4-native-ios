//
//  dydxSimpleUITradeStatusView.swift
//  dydxUI
//
//  Created by Rui Huang on 20/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeStatusViewModel: PlatformViewModel {
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

    @Published public var totalAmount: String?
    @Published public var totalFees: String?
    @Published public var side: AppOrderSide?
    @Published public var price: String?
    @Published public var size: String?
    @Published public var assetId: String?

    @Published public var status = StatusIcon.submitting
    @Published public var ctaButtonViewModel = dydxTradeStatusCtaButtonViewModel()

    public init() {
        super.init()

        ctaButtonViewModel.buttonType = PlatformButtonType.defaultType(
            fillWidth: true,
            pilledCorner: false,
            minHeight: 60,
            cornerRadius: 16)
    }

    public static var previewValue: dydxSimpleUITradeStatusViewModel {
        let vm = dydxSimpleUITradeStatusViewModel()
        vm.totalAmount = "$100.00"
        vm.totalFees = "$1.00"
        vm.side = .BUY
        vm.price = "$100.00"
        vm.size = "100.00"
        vm.assetId = "BTC"
        vm.status = .submitting
        vm.ctaButtonViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
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
                .themeColor(background: .layer2)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createCenterItems(style: ThemeStyle) -> some View {
        let sideColor: ThemeColor.SemanticColor
        let sideText: String?
        switch side {
        case .BUY:
            sideColor = ThemeColor.SemanticColor.colorGreen
            sideText = DataLocalizer.localize(path: "APP.GENERAL.BUY")
        case .SELL:
            sideColor = ThemeColor.SemanticColor.colorRed
            sideText = DataLocalizer.localize(path: "APP.GENERAL.SELL")
        default:
            sideColor = ThemeColor.SemanticColor.textSecondary
            sideText = nil
        }

        return VStack(spacing: 24) {

            VStack(spacing: 16) {
                self.createIcon(style: style)
                Text(status.title)
                    .themeFont(fontType: .plus, fontSize: .larger)
                    .themeColor(foreground: .textPrimary)
            }

            VStack(spacing: 8) {
                HStack {
                    Text(sideText ?? "-")
                        .themeColor(foreground: sideColor)
                    Text(size ?? "-")
                        .themeColor(foreground: .textPrimary)
                    Text(assetId ?? "-")
                        .themeColor(foreground: .textPrimary)
                }
                .themeFont(fontType: .plus, fontSize: .largest)

                HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.PRICE") + ":")
                        .themeColor(foreground: .textTertiary)
                    Text(price ?? "-")
                        .themeColor(foreground: .textSecondary)

                }
            }
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
                    Text(DataLocalizer.localize(path: "APP.TRADE.TOTAL") + ":")
                        .themeColor(foreground: .textTertiary)
                    Text(self.totalAmount ?? "-")
                        .themeColor(foreground: .textPrimary)
                }
                .themeFont(fontSize: .small)

                Spacer()

                if let totalFees = self.totalFees {
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.COST") + ":")
                            .themeColor(foreground: .textTertiary)
                        Text(totalFees)
                            .themeColor(foreground: .textPrimary)
                    }
                    .themeFont(fontSize: .small)
                }
            }
            ctaButtonViewModel.createView(parentStyle: style)
        }
    }
}

#if DEBUG
struct dydxSimpleUITradeStatusView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUITradeStatusView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
