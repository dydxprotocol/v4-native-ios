//
//  dydxTransferSelectorView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/08/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferSelectorViewModel: PlatformViewModel {
    public enum Action {
        case deposit, withdrawal, transferOut, faucet
    }

    public var onAction: ((Action) -> Void)?
    public var isMainnet: Bool = true

    public init() { }

    public static var previewValue: dydxTransferSelectorViewModel {
        let vm = dydxTransferSelectorViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading) {
                self.createButton(title: DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"),
                                  subtitle: DataLocalizer.localize(path: "APP.ONBOARDING.DEPOSIT_DESC"),
                                  imageName: "icon_transfer_deposit_2",
                                  action: Action.deposit,
                                  style: style)

                self.createButton(title: DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW"),
                                  subtitle: DataLocalizer.localize(path: "APP.ONBOARDING.WITHDRAWAL_DESC"),
                                  imageName: "icon_transfer_withdrawal_2",
                                  action: Action.withdrawal,
                                  style: style)

                self.createButton(title: DataLocalizer.localize(path: "APP.GENERAL.TRANSFER_OUT"),
                                  subtitle: DataLocalizer.localize(path: "APP.ONBOARDING.TRANSFEROUT_DESC"),
                                  imageName: "icon_swap_vertical",
                                  action: Action.transferOut,
                                  style: style)

                if self.isMainnet == false {
                    self.createButton(title: DataLocalizer.localize(path: "Faucet"),
                                      subtitle: "",
                                      imageName: "icon_transfer_deposit",
                                      action: Action.faucet,
                                      style: style)
                }
            }
                .padding(.horizontal)
                .padding(.top, 40)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createButton(title: String, subtitle: String, imageName: String, action: Action, style: ThemeStyle) -> some View {
        Button { [weak self] in
            self?.onAction?(action)
        } label: {
            HStack(alignment: .center, spacing: 16) {
                PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                      size: CGSize(width: 24, height: 24),
                                      templateColor: .textPrimary)
                .createView(parentStyle: style)

                VStack(alignment: .leading) {
                    Text(title)
                        .themeColor(foreground: .textPrimary)

                    Text(subtitle)
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)
                }

                Spacer()

                PlatformIconViewModel(type: .asset(name: "icon_chevron", bundle: Bundle.dydxView),
                                      size: CGSize(width: 12, height: 12),
                                      templateColor: .textTertiary)
                .createView(parentStyle: style)
            }
            .padding(.vertical, 8)
        }
    }
}

#if DEBUG
struct dydxTransferSelectorView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferSelectorViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferSelectorView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferSelectorViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
