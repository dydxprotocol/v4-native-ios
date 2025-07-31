//
//  dydxWalletListView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/28/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import Introspect

public class dydxWalletListViewModel_Deprecated: PlatformViewModel {
    @Published public var items: [PlatformViewModel] = []
    @Published public var onScrollViewCreated: ((UIScrollView) -> Void)?
    @Published public var onBackButtonTapped: (() -> Void)?

    public init() { }

    public static var previewValue: dydxWalletListViewModel_Deprecated {
        let vm = dydxWalletListViewModel_Deprecated()
        vm.items = [
            dydxWalletViewModel.previewValue,
            dydxWalletViewModel.previewValue
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 8) {

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center) {
                        if let onBackButtonTapped = self.onBackButtonTapped {
                            ChevronBackButtonModel(onBackButtonTap: onBackButtonTapped)
                                .createView(parentStyle: style)
                        }

                        Text(DataLocalizer.localize(path: "APP.ONBOARDING.SELECT_WALLET"))
                            .themeFont(fontSize: .larger)
                            .themeColor(foreground: .textPrimary)
                    }

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.SELECT_WALLET_TEXT"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .leftAligned()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {

                        ForEach(self.items, id: \.id) { lineItem in
                            lineItem
                                .createView(parentStyle: style)
                                .frame(maxWidth: .infinity)
                        }
                        .animation(.default)

                        Spacer(minLength: 28)
                    }
                    .introspectScrollView { [weak self] scrollView in
                        self?.onScrollViewCreated?(scrollView)
                    }
                }
            }
                .padding([.leading, .trailing])
                .themeColor(background: .layer1)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxWalletListView_Deprecated_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxWalletListViewModel_Deprecated.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxWalletListView_Deprecated_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxWalletListViewModel_Deprecated.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
