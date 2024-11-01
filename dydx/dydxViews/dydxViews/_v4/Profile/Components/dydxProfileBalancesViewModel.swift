//
//  dydxProfileBalancesViewModel.swift
//  dydxUI
//
//  Created by Rui Huang on 9/18/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileBalancesViewModel: PlatformViewModel {
    @Published public var walletAmount: String?
    @Published public var stakedAmount: String?
    @Published public var totalAmount: String?
    @Published public var transferAction: (() -> Void)?
    @Published public var nativeTokenName: String?
    @Published public var nativeTokenLogoUrl: URL?

    public init() { }

    public static var previewValue: dydxProfileBalancesViewModel {
        let vm = dydxProfileBalancesViewModel()
        vm.walletAmount = "20.00"
        vm.stakedAmount = "30.00"
        vm.totalAmount = "50.00"
        vm.nativeTokenName = "DYDX"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 16) {
                    self.createHeader(style: parentStyle)

                    HStack(spacing: 16) {
                        self.createAmountPanel(style: parentStyle,
                                               title: DataLocalizer.localize(path: "APP.GENERAL.WALLET"),
                                               amount: self.walletAmount ?? "-")

                        self.createAmountPanel(style: parentStyle,
                                               title: DataLocalizer.localize(path: "APP.GENERAL.STAKED"),
                                               amount: self.stakedAmount ?? "-")
                    }

                    self.createFooter(style: parentStyle)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .themeColor(background: .layer3)
                .cornerRadius(14, corners: .allCorners)
            )
        }
    }

    private func createHeader(style: ThemeStyle) -> some View {
        HStack {
            if let nativeTokenLogoUrl = nativeTokenLogoUrl {
                PlatformIconViewModel(type: .url(url: nativeTokenLogoUrl),
                                      size: CGSize(width: 24, height: 24))
                .createView(parentStyle: style)
            }

            Text(nativeTokenName ?? "")
                .themeColor(foreground: .textSecondary)
                .themeFont(fontSize: .medium)

            Spacer()

            if transferAction != nil {
                let buttonContent = HStack {
                    PlatformIconViewModel(type: .asset(name: "icon_transfer_dydx", bundle: Bundle.dydxView),
                                          size: CGSize(width: 13, height: 13),
                                          templateColor: .colorWhite)
                    .createView(parentStyle: style)
                    Text(DataLocalizer.localize(path: "APP.GENERAL.TRANSFER"))
                        .themeColor(foreground: .colorWhite)
                        .themeFont(fontSize: .small)
                }
                    .wrappedViewModel
                PlatformButtonViewModel(content: buttonContent,
                                        type: .small) { [weak self] in
                    self?.transferAction?()
                }
                                        .createView(parentStyle: style)
            }
        }
    }

    private func createAmountPanel(style: ThemeStyle, title: String, amount: String) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .themeColor(foreground: .textSecondary)
                .themeFont(fontSize: .small)
                .leftAligned()

            Text(amount)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .number, fontSize: .largest)
                .leftAligned()

        }
        .padding(16)
        .themeColor(background: .layer4)
        .cornerRadius(10, corners: .allCorners)
        .frame(maxWidth: .infinity)
    }

    private func createFooter(style: ThemeStyle) -> some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.GENERAL.TOTAL_BALANCE"))
            Spacer()
            Text(totalAmount ?? "-")
                .themeColor(foreground: .textPrimary)
            Text(nativeTokenName ?? "")
        }
        .themeColor(foreground: .textTertiary)
        .themeFont(fontSize: .small)
    }

}

#if DEBUG
struct dydxProfileBalancesViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileBalancesViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileBalancesViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileBalancesViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
