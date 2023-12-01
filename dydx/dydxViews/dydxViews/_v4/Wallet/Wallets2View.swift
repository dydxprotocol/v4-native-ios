//
//  Wallets2ViewModel.swift
//  dydxViews
//
//  Created by Rui Huang on 8/29/22.
//

import SwiftUI
import PlatformUI
import Utilities

public class Wallets2ViewModel: PlatformViewModel {
    @Published public var walletConnections = [WalletConnectionViewModel]()

    public var buttonAction: (() -> Void)?

    public init(buttonAction: (() -> Void)? = nil) {
        self.buttonAction = buttonAction
    }

    public static var previewValue: Wallets2ViewModel = {
        let vm = Wallets2ViewModel(buttonAction: nil)
        vm.walletConnections =  [WalletConnectionViewModel.previewValue]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 16) {
                Text(DataLocalizer.localize(path: "APP.GENERAL.MANAGE_WALLET", params: nil))
                    .themeFont(fontType: .bold, fontSize: .largest)
                    .padding(.top, 40)
                    .padding(.leading, 16)

                VStack {
                    ForEach(self.walletConnections, id: \.id) { walletConnection in
                        walletConnection.createView(parentStyle: style)
                    }
                }

                let buttonContent =
                    Text(DataLocalizer.localize(path: "APP.GENERAL.ADD_NEW_WALLET", params: nil))
                PlatformButtonViewModel(content: PlatformViewModel { _ in  AnyView(buttonContent) },
                                        state: .primary,
                                        action: { self.buttonAction?() })
                .createView(parentStyle: style)

                Spacer()
            }
                .padding(.horizontal)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))

        }
    }
}

#if DEBUG
struct Wallets2View_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return Wallets2ViewModel.previewValue.createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct Wallets2View_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return Wallets2ViewModel.previewValue.createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
