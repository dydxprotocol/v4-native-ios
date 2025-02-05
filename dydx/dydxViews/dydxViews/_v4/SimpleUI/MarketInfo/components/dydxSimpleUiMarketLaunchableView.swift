//
//  dydxSimpleUiMarketLaunchableView.swift
//  dydxUI
//
//  Created by Rui Huang on 01/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxSimpleUiMarketLaunchableViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var ctaAction: (() -> Void)?
    @Published public var minDeposit: Double?
    @Published public var thirtyDayReturnPercent: Double?
    @Published public var faqAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUiMarketLaunchableViewModel {
        let vm = dydxSimpleUiMarketLaunchableViewModel()
        vm.sharedMarketViewModel = .previewValue
        vm.minDeposit = 100000
        vm.thirtyDayReturnPercent = 0.2
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 24) {
                self.createLaunchableText(style: style)
                self.createHeader(style: style)
                self.createDetails(style: style)
                Spacer()
                self.createButton(style: style)
            }
                .padding(.top, 24)
                .padding(.horizontal, 20)

            return AnyView(view)
        }
    }

    private func createLaunchableText(style: ThemeStyle) -> some View {
        HStack {
            Spacer()
            PlatformIconViewModel(type: .system(name: "info.circle.fill"),
                                  size: CGSize(width: 20, height: 20),
                                  templateColor: .textTertiary)
            .createView(parentStyle: style)
            Text(DataLocalizer.localize(path: "APP.GENERAL.LAUNCHABLE_DETAILS"))
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .small)
            Spacer()
        }
        .padding(12)
        .borderAndClip(style: .cornerRadius(8), borderColor: .borderDefault)
    }

    private func createHeader(style: ThemeStyle) -> some View {
        HStack(alignment: .center) {
            Text(DataLocalizer.localize(path: "APP.GENERAL.DETAILS"))
                .themeFont(fontType: .plus, fontSize: .large)
                .themeColor(foreground: .textPrimary)

            Spacer()

            HStack {
                dydxSimpleUIMarketDetailsViewModel.createIconButton(url: sharedMarketViewModel?.coinMarketPlaceUrl, iconAssetName: "icon_coinmarketcap", style: style)
                dydxSimpleUIMarketDetailsViewModel.createIconButton(url: sharedMarketViewModel?.whitepaperUrl, iconAssetName: "icon_whitepaper", style: style)
                dydxSimpleUIMarketDetailsViewModel.createIconButton(url: sharedMarketViewModel?.websiteUrl, iconAssetName: "icon_web", style: style)
            }
        }
    }

    private func createDetails(style: ThemeStyle) -> some View {
        VStack(alignment: .leading) {
            HStack {
                let nameHeader = Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET_NAME"))
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: nameHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.assetName)
                .frame(minWidth: 0, maxWidth: .infinity)

                let marketCapHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET_CAP"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD", withBorder: true)
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: marketCapHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.marketCap)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxHeight: 72)

            HStack {
                let volumeCapHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.TRADE.SPOT_VOLUME_24H"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD", withBorder: true)
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: volumeCapHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.spotVolume24H)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxHeight: 72)

        }
    }

    private func createButton(style: ThemeStyle) -> some View {
        let aprAttributedString: AttributedString?
        if let aprValue = dydxFormatter.shared.percent(number: thirtyDayReturnPercent, digits: 2) {

            let aprText = DataLocalizer.localize(path: "APP.VAULT.LAUNCH_MARKET_LINE2")
            var result = AttributedString(aprText)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textTertiary, to: nil)

            let paramText = AttributedString(aprValue)
            if let range = result.range(of: "{APR}") {
                result.replaceSubrange(range, with: paramText.themeColor(foreground: .colorGreen)
                    .themeFont(fontSize: .small))
            }
            aprAttributedString = result
        } else {
            aprAttributedString = nil
        }

        return VStack(spacing: 16) {
            VStack(spacing: 4) {
                if let depositValue = dydxFormatter.shared.dollarVolume(number: minDeposit) {
                    Text(DataLocalizer.localize(path: "APP.VAULT.LAUNCH_MARKET_LINE1", params: ["DEPOSIT_AMOUNT": depositValue]))
                        .themeFont(fontSize: .medium)
                }
                if let aprAttributedString {
                    Text(aprAttributedString)
                }
            }
            .onTapGesture { [weak self] in
                self?.faqAction?()
            }

            let buttonType = PlatformButtonType.defaultType(
                fillWidth: true,
                pilledCorner: false,
                minHeight: 60,
                cornerRadius: 16)

            let buttonText = DataLocalizer.localize(path: "APP.GENERAL.LAUNCH_ON_WEB")
            let buttonContent = HStack {
                Text(buttonText)
                PlatformIconViewModel(type: .asset(name: "icon_external_link", bundle: Bundle.dydxView),
                                      size: CGSize(width: 20, height: 20),
                                      templateColor: .textPrimary)
                .createView(parentStyle: style)
            }
                .wrappedViewModel

            PlatformButtonViewModel(content: buttonContent,
                                    type: buttonType,
                                    state: .primary) { [weak self] in
                PlatformView.hideKeyboard()
                self?.ctaAction?()
            }
                                    .createView(parentStyle: style)
        }

    }

}

#if DEBUG
struct dydxSimpleUiMarketLaunchableView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUiMarketLaunchableViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUiMarketLaunchableView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUiMarketLaunchableViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
