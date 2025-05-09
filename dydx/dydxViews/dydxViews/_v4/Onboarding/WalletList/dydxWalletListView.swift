//
//  dydxWalletListView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxWalletListViewModel: PlatformViewModel {
    @Published public var socialView: dydxSocialViewModel?
    @Published public var syncDesktopView: dydxSyncDesktopViewModel?
    @Published public var debugView: dydxDebugScanViewModel?
    @Published public var metamaskView: dydxMetamaskViewModel?
    @Published public var phantomView: dydxPhantomViewModel?
    @Published public var coinbaseView: dydxCoinbaseViewModel?
    @Published public var wcModalView: dydxWcModalViewModel?

    @Published public var onScrollViewCreated: ((UIScrollView) -> Void)?

    public init() { }

    public static var previewValue: dydxWalletListViewModel {
        let vm = dydxWalletListViewModel()
        vm.socialView = .previewValue
        vm.syncDesktopView = .previewValue
        vm.debugView = .previewValue
        vm.metamaskView = .previewValue
        vm.phantomView = .previewValue
        vm.coinbaseView = .previewValue
        vm.wcModalView = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 8) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.SELECT_WALLET"))
                        .themeFont(fontSize: .largest)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.LOGIN_SIGNUP_TEXT_2"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .leftAligned()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        self.syncDesktopView?.createView(parentStyle: style)
                        self.debugView?.createView(parentStyle: style)
                        self.metamaskView?.createView(parentStyle: style)
                        self.phantomView?.createView(parentStyle: style)
                        self.coinbaseView?.createView(parentStyle: style)
                        self.wcModalView?.createView(parentStyle: style)

                        self.createDivider(parentStyle: style)

                        self.socialView?.createView(parentStyle: style)

                        Spacer(minLength: 28)
                    }
                    .padding(.top, 16)
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

    private func createDivider(parentStyle: ThemeStyle) -> some View {
        ZStack(alignment: .center) {
            DividerModel().createView(parentStyle: parentStyle)
            Text(DataLocalizer.localize(path: "APP.GENERAL.OR"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
                .padding(.horizontal, 8)
                .themeColor(background: .layer1)
        }
    }
}

#if DEBUG
struct dydxWalletListView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxWalletListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxWalletListView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxWalletListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
