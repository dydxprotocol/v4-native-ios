//
//  dydxSimpleUIMenuAccountView.swift
//  dydxUI
//
//  Created by Rui Huang on 19/04/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMenuAccountViewModel: PlatformViewModel {
    public enum AddressType {
        case dydx
        case source
    }
    @Published public var balance: String?
    @Published public var address: String?
    @Published public var addressAction: (() -> Void)?
    @Published public var switchAction: (() -> Void)?
    @Published public var addressType: AddressType = .dydx

    public init() { }

    public static var previewValue: dydxSimpleUIMenuAccountViewModel {
        let vm = dydxSimpleUIMenuAccountViewModel()
        vm.balance = "$1000.00"
        vm.address = "dydx11...12222"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                HStack(spacing: 16) {
                    self.createIcon(parentStyle: style)

                    VStack {
                        Text(self.balance ?? "-")
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .large)
                            .leftAligned()

                        Text(DataLocalizer.localize(path: "APP.GENERAL.BALANCE"))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)
                            .leftAligned()
                    }

                    Spacer()
                }

                HStack {
                    self.createAddressCopy(parentStyle: parentStyle)
                    Spacer()
                    self.createAddressSwitch(parentStyle: parentStyle)
                }
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .borderAndClip(style: .cornerRadius(20), borderColor: ThemeColor.SemanticColor.borderDefault)

            return AnyView(view)
        }
    }

    private func createIcon(parentStyle: ThemeStyle) -> some View {
        ZStack {
            PlatformIconViewModel(type: .asset(name: "logo_hedgie_2", bundle: .dydxView),
                                  size: CGSize(width: 50, height: 50))
            .createView(parentStyle: parentStyle)
            .themeColor(background: .colorPurple)
            .cornerRadius(16, corners: .allCorners)
            .frame(width: 50, height: 50)

            PlatformIconViewModel(type: .asset(name: "icon_dydx", bundle: .dydxView),
                                  size: CGSize(width: 22, height: 22))
            .createView(parentStyle: parentStyle)
            .borderAndClip(style: .circle, borderColor: .layer2, lineWidth: 2)
            .rightAligned()
            .bottomAligned()
            .offset(x: 2, y: 2)
        }
        .frame(width: 54, height: 54)
    }

    private func createAddressCopy(parentStyle: ThemeStyle) -> some View {
        Button {  [weak self] in
            self?.addressAction?()
        } label: {
            HStack(spacing: 12) {
                Text(self.address ?? "-")
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .small)

                PlatformIconViewModel(type: .asset(name: "icon_copy", bundle: Bundle.dydxView),
                                      size: CGSize(width: 16, height: 16),
                                      templateColor: .textTertiary)
                    .createView(parentStyle: parentStyle)

            }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .themeColor(background: .layer3)
                .clipShape(.capsule)
        }
    }

    private func createAddressSwitch(parentStyle: ThemeStyle) -> some View {
        let addressText: String
        switch self.addressType {
        case .dydx:
            addressText = DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS")
        case .source:
            addressText = DataLocalizer.localize(path: "APP.V4.SOURCE_ADDRESS")
        }

        return Button {  [weak self] in
            self?.switchAction?()
        } label: {
             HStack(spacing: 8) {
                Text(addressText)
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .smaller)

                PlatformIconViewModel(type: .asset(name: "icon_dropdown", bundle: Bundle.dydxView),
                                      size: CGSize(width: 14, height: 14),
                                      templateColor: .textTertiary)
                    .createView(parentStyle: parentStyle)

            }
                .padding(.vertical, 8)
        }
    }

}

#if DEBUG
struct dydxSimpleUIMenuAccountView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMenuAccountViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMenuAccountView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMenuAccountViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
