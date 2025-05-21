//
//  dydxInstantDepositSearchItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 21/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxInstantDepositSearchItemViewModel: PlatformViewModel {
    @Published public var token: String?
    @Published public var chain: String?
    @Published public var tokenIcon: URL?
    @Published public var chainIcon: URL?
    @Published public var tokenSize: String?
    @Published public var usdcSize: String?
    @Published public var selected: Bool = false
    @Published public var selectAction: (() -> Void)?

    public var id: String {
        (token ?? "") + (chain ?? "")
    }

    public init() { }

    public static var previewValue: dydxInstantDepositSearchItemViewModel {
        let vm = dydxInstantDepositSearchItemViewModel()
        vm.token = "ETH"
        vm.chain = "Ethereum"
        vm.chainIcon = URL(string: "https://v4.testnet.dydx.exchange/chains/ethereum.png")
        vm.tokenIcon = URL(string: "https://v4.testnet.dydx.exchange/currencies/usdc.png")
        vm.tokenSize = "1000"
        vm.usdcSize = "$1000"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 8) {
                ZStack {
                    PlatformIconViewModel(type: .url(url: self.tokenIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 32, height: 32))
                        .createView(parentStyle: style)

                    PlatformIconViewModel(type: .url(url: self.chainIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 18, height: 18))
                        .createView(parentStyle: style)
                        .borderAndClip(style: .circle, borderColor: .layer3, lineWidth: 2)
                        .rightAligned()
                        .bottomAligned()
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading) {
                    Text(self.token ?? "")
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textPrimary)
                    Text(self.chain ?? "")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(self.tokenSize ?? "")
                        .themeFont(fontSize: .medium)
                    Text(self.usdcSize ?? "")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .themeColor(background: .layer3)
                .cornerRadius(12)
                .if(self.selected) { view in
                    view.borderAndClip(style: .cornerRadius(12), borderColor: .colorPurple, lineWidth: 2)
                }
                .onTapGesture { [weak self] in
                    self?.selectAction?()
                }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxInstantDepositSearchItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositSearchItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxInstantDepositSearchItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositSearchItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
