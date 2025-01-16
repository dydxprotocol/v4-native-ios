//
//  dydxSimpleUIMarketInfoHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import Foundation

public class dydxSimpleUIMarketInfoHeaderViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var onBackButtonTap: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketInfoHeaderViewModel {
        let vm = dydxSimpleUIMarketInfoHeaderViewModel()
        vm.sharedMarketViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return HStack(spacing: 8) {
                ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                    .createView(parentStyle: style)
                    .frame(width: 32)

                self.createIcon(style: style)

                self.createNameVolume(style: style)

                Spacer()

                self.createPriceChange(style: style)
            }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .wrappedInAnyView()
        }
    }

    private func createIcon(style: ThemeStyle) -> some View {
        let placeholderText = { [weak self] in
            if let assetName = self?.sharedMarketViewModel?.assetName {
                return Text(assetName.prefix(1))
                    .frame(width: 32, height: 32)
                    .themeColor(foreground: .textTertiary)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
                    .wrappedInAnyView()
            }
            return AnyView(PlatformView.nilView)
        }
        let iconType = PlatformIconViewModel.IconType.url(url: sharedMarketViewModel?.logoUrl, placeholderContent: placeholderText)
        return PlatformIconViewModel(type: iconType,
                                     clip: .circle(background: .transparent, spacing: 0),
                                     size: CGSize(width: 32, height: 32))
            .createView(parentStyle: style)
    }

    private func createNameVolume(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sharedMarketViewModel?.assetId ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            HStack {
                Text(DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS._24H_VOLUME"))
                    .themeColor(foreground: .textTertiary)

                Text(sharedMarketViewModel?.volume24H ?? "")
                    .themeColor(foreground: .textSecondary)
            }
            .themeFont(fontSize: .small)
        }
    }

    private func createPriceChange(style: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(sharedMarketViewModel?.indexPrice ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            sharedMarketViewModel?.priceChangePercent24H?.createView(parentStyle: style.themeFont(fontSize: .small))
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketInfoHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketInfoHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
