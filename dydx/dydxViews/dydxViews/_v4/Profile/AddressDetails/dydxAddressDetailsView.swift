//
//  dydxAddressDetailsView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import RoutingKit

public class dydxAddressDetailsViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var dydxChainLogoUrl: URL?
    @Published public var dydxAddress: String?
    @Published public var sourceAddress: String?
    @Published public var sourceWalletImageUrl: URL?
    @Published public var copyAddressAction: (() -> Void)?
    @Published public var etherscanAction: (() -> Void)?
    @Published public var keyExportAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxAddressDetailsViewModel {
        let vm = dydxAddressDetailsViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    self.createHeader(parentStyle: style)
                                      .frame(height: 48)
                                      .padding([.leading, .trailing])

                    self.createDydxAddressView(parentStyle: style)

                    /*
                     TODO: source address should be different than dydx address. This if condition should evntually be removed before production launch.
                     When this comment was made, the "sync with desktop" flow would not bring over the source address from web app. This will have to change
                     before this if can be removed.
                     */
                    if self.sourceAddress != self.dydxAddress {
                        self.createSourceAddressView(parentStyle: style)
                    }

                    DividerModel().createView(parentStyle: style)

                    self.createEtherscanView(parentStyle: style)

                    DividerModel().createView(parentStyle: style)

                    self.createKeyExportView(parentStyle: style)

                    DividerModel().createView(parentStyle: style)

                    Spacer()
                }
                .themeColor(background: .layer2)
                .animation(.default)
            )
        }
    }

    private func createHeader(parentStyle: ThemeStyle) -> some View {
        HStack {
            PlatformButtonViewModel(content: PlatformIconViewModel(type: .system(name: "chevron.left"), size: CGSize(width: 16, height: 16)), type: .iconType) {
                Router.shared?.navigate(to: RoutingRequest(url: "/action/dismiss"), animated: true, completion: nil)
            }
            .createView(parentStyle: parentStyle)

            Text(DataLocalizer.localize(path: "APP.GENERAL.PROFILE", params: nil))
                .themeFont(fontType: .bold, fontSize: .largest)

            Spacer()
        }
    }

    private func createDydxAddressView(parentStyle: ThemeStyle) -> some View {
        let icon = PlatformIconViewModel(type: .url(url: dydxChainLogoUrl),
                                         size: CGSize(width: 64, height: 64))
        let main = VStack(alignment: .leading, spacing: 4) {
            Text(DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS"))
                .themeFont(fontSize: .small)

            Text(self.dydxAddress ?? "-")
                .themeColor(foreground: .textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        let copyText = Text(DataLocalizer.localize(path: "APP.GENERAL.COPY"))
            .themeFont(fontSize: .small)
        let trailing = PlatformButtonViewModel(content: copyText.wrappedViewModel, type: .pill, state: .secondary) { [weak self] in
            self?.copyAddressAction?()
        }
        return PlatformTableViewCellViewModel(leading: icon,
                                           main: main.wrappedViewModel,
                                           trailing: trailing)
            .createView(parentStyle: parentStyle)
    }

    private func createSourceAddressView(parentStyle: ThemeStyle) -> some View {
        let icon: PlatformViewModel
        if let sourceWalletImageUrl = sourceWalletImageUrl {
            icon = PlatformIconViewModel(type: .url(url: sourceWalletImageUrl),
                                         clip: .circle(background: .layer4, spacing: 0),
                                         size: CGSize(width: 64, height: 64))
        } else {
            icon = PlatformIconViewModel(type: .system(name: "folder"),
                                         clip: .circle(background: .layer4, spacing: 32),
                                         size: CGSize(width: 64, height: 64))
        }
        let main = VStack(alignment: .leading, spacing: 4) {
            Text(DataLocalizer.localize(path: "APP.V4.SOURCE_ADDRESS"))
                .themeFont(fontSize: .small)

            Text(self.sourceAddress ?? "-")
                .themeColor(foreground: .textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        let trailing = PlatformView.nilViewModel
        return PlatformTableViewCellViewModel(leading: icon,
                                           main: main.wrappedViewModel,
                                           trailing: trailing)
            .createView(parentStyle: parentStyle)
    }

    private func createEtherscanView(parentStyle: ThemeStyle) -> some View {
        let main = Text(DataLocalizer.localize(path: "APP.HEADER.OPEN_IN_ETHERSCAN"))
        let trailing =  PlatformIconViewModel(type: .system(name: "chevron.right"), size: CGSize(width: 16, height: 16))
        return PlatformTableViewCellViewModel(main: main.wrappedViewModel,
                                       trailing: trailing)
            .createView(parentStyle: parentStyle)
            .onTapGesture { [weak self] in
                self?.etherscanAction?()
            }
    }

    private func createKeyExportView(parentStyle: ThemeStyle) -> some View {
        let main = Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.EXPORT_SECRET_PHRASE"))
        let trailing =  PlatformIconViewModel(type: .system(name: "chevron.right"), size: CGSize(width: 16, height: 16))
        return PlatformTableViewCellViewModel(main: main.wrappedViewModel,
                                       trailing: trailing)
            .createView(parentStyle: parentStyle)
            .onTapGesture { [weak self] in
                self?.keyExportAction?()
            }
    }
}

#if DEBUG
struct dydxAddressDetailsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAddressDetailsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAddressDetailsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAddressDetailsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
