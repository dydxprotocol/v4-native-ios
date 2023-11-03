//
//  dydxProfileFeesView.swift
//  dydxUI
//
//  Created by Rui Huang on 8/8/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileFeesViewModel: PlatformViewModel, Equatable {
    public static func == (lhs: dydxProfileFeesViewModel, rhs: dydxProfileFeesViewModel) -> Bool {
        lhs.tradingVolume == rhs.tradingVolume &&
        lhs.takerFeeRate == rhs.takerFeeRate &&
        lhs.makerFeeRate == rhs.makerFeeRate
    }

    @Published public var tradingVolume: String?
    @Published public var takerFeeRate: String?
    @Published public var makerFeeRate: String?
    @Published public var tapAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxProfileFeesViewModel {
        let vm = dydxProfileFeesViewModel()
        vm.tradingVolume = "$120,000"
        vm.takerFeeRate = "0.01%"
        vm.makerFeeRate = "0.01%"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.FEES"))
                        .themeFont(fontSize: .small)
                    Spacer()
                    PlatformIconViewModel(type: .system(name: "chevron.right"),
                                          size: CGSize(width: 10, height: 10),
                                          templateColor: .textSecondary)
                    .createView(parentStyle: style)
                }
                .padding()

                DividerModel()
                    .createView(parentStyle: style)

                VStack(spacing: 16) {
                    HStack {
                        VStack(spacing: 8) {
                            Text(DataLocalizer.localize(path: "APP.TRADE.TAKER"))
                                .themeFont(fontType: .text, fontSize: .smaller)
                                .leftAligned()

                            Text(self.takerFeeRate ?? "-")
                                .themeFont(fontType: .text, fontSize: .small)
                                .themeColor(foreground: .textPrimary)
                                .leftAligned()
                        }

                        VStack(spacing: 8) {
                            Text(DataLocalizer.localize(path: "APP.TRADE.MAKER"))
                                .themeFont(fontType: .text, fontSize: .smaller)
                                .leftAligned()

                            Text(self.makerFeeRate ?? "-")
                                .themeFont(fontType: .text, fontSize: .small)
                                .themeColor(foreground: .textPrimary)
                                .leftAligned()
                        }
                    }

                    VStack(spacing: 8) {
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.TRADE.VOLUME"))

                            Text(DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.30D"))
                                .themeColor(foreground: .textTertiary)
                        }
                        .themeFont(fontType: .text, fontSize: .smaller)
                        .leftAligned()

                        Text(self.tradingVolume ?? "-")
                            .themeFont(fontType: .text, fontSize: .small)
                            .themeColor(foreground: .textPrimary)
                            .leftAligned()
                    }
                }
                .padding(16)
            }
            .themeColor(background: .layer4)
            .cornerRadius(12, corners: .allCorners)
            .onTapGesture { [weak self] in
                self?.tapAction?()
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxProfileFeesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileFeesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileFeesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileFeesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
