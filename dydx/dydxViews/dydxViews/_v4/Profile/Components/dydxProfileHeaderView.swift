//
//  dydxProfileHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileHeaderViewModel: PlatformViewModel {
    @Published public var dydxChainLogoUrl: URL?
    @Published public var dydxAddress: String?
    @Published public var copyAction: (() -> Void)?
    @Published public var openInEtherscanAction: (() -> Void)?
    @Published public var manageWalletAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxProfileHeaderViewModel {
        let vm = dydxProfileHeaderViewModel()
        vm.dydxAddress = "dydx11111111111111111111111"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let chainIcon = PlatformIconViewModel(type: self.dydxAddress != nil ? .url(url: self.dydxChainLogoUrl) : .asset(name: "hedgie_placeholder", bundle: Bundle.dydxView),
                                             size: CGSize(width: 64, height: 64))
            let dropDownIcon = PlatformIconViewModel(type: .asset(name: "icon_dropdown", bundle: Bundle.dydxView),
                                                     clip: .noClip,
                                                     size: .init(width: 14, height: 8),
                                                     templateColor: .textTertiary)
            let manageWalletButton = HStack(spacing: 9) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MANAGE_WALLET"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    dropDownIcon.createView(parentStyle: parentStyle)
                }
                .onTapGesture { [weak self] in
                    self?.manageWalletAction?()
                }

            let addressInfoView = VStack(alignment: .leading, spacing: 4) {
                Text(DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)

                Text(self.dydxAddress ?? "-")
                    .themeColor(foreground: .textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            let iconDim: CGFloat = 40
            let iconSpacing: CGFloat = 18

            let copyButton: Button? = copyAction == nil ? nil : Button { [weak self] in
                if let copyAction = self?.copyAction {
                    copyAction()
                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS_COPIED"),
                                           type: .info,
                                           error: nil, time: 3)
                }
            } label: {
                PlatformIconViewModel(type: .asset(name: "icon_copy", bundle: .dydxView),
                                      clip: .circle(background: .layer4, spacing: iconSpacing, borderColor: .layer6),
                                      size: CGSize(width: iconDim, height: iconDim))
                    .createView()
            }

            let openInEtherscanAction: Button? = openInEtherscanAction == nil ? nil : Button { [weak self] in
                self?.openInEtherscanAction?()
            } label: {
                PlatformIconViewModel(type: .asset(name: "icon_external_link", bundle: .dydxView),
                                      clip: .circle(background: .layer4, spacing: iconSpacing, borderColor: .layer6),
                                      size: CGSize(width: iconDim, height: iconDim))
                    .createView()
            }

            let content = VStack(spacing: 16) {
                HStack(alignment: .top) {
                    chainIcon
                        .createView(parentStyle: parentStyle)
                    Spacer()
                    if self.dydxAddress?.isEmpty == false {
                        manageWalletButton
                    }
                }
                HStack(spacing: 0) {
                    addressInfoView
                    Spacer(minLength: 12)
                    HStack(spacing: 12) {
                        copyButton
                        openInEtherscanAction
                    }
                }
            }
                .padding(.all, 20)
                .themeColor(background: .layer4)
                .cornerRadius(12, corners: .allCorners)
            return AnyView(content)
        }
    }
}

#if DEBUG
struct dydxProfileHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
