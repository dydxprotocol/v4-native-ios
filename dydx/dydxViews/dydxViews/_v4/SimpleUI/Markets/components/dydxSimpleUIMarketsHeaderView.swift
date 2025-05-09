//
//  dydxSimpleUIMarketsHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketsHeaderViewModel: PlatformViewModel {
    @Published public var onboarded: Bool = false

    @Published public var depositAction: (() -> Void)?
    @Published public var withdrawAction: (() -> Void)?
    @Published public var menuAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketsHeaderViewModel {
        let vm = dydxSimpleUIMarketsHeaderViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(alignment: .center, spacing: 16) {
                Spacer()

                if self.depositAction != nil {
                    self.createDepositButton(parentStyle: style)
                }

                if self.withdrawAction != nil {
                    self.createWithdrawButton(parentStyle: style)
                }

                self.createMenuButton(parentStyle: style)
            }

            return AnyView(view)
        }
    }

    private func createDepositButton(parentStyle: ThemeStyle) -> some View {
        let iconName = "icon_transfer_deposit"
        let content = PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                            clip: .circle(background: .layer5, spacing: 16, borderColor: .layer6),
                                            size: CGSize(width: 36, height: 36),
                                            templateColor: .textPrimary)
        return PlatformButtonViewModel(content: content,
                                       type: .iconType) { [weak self] in
            self?.depositAction?()
        }
                                       .createView(parentStyle: parentStyle)
    }

    private func createWithdrawButton(parentStyle: ThemeStyle) -> some View {
        let iconName = "icon_transfer_withdrawal"
        let content = PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                            clip: .circle(background: .layer5, spacing: 16, borderColor: .layer6),
                                            size: CGSize(width: 36, height: 36),
                                            templateColor: .textPrimary)
        return PlatformButtonViewModel(content: content,
                                       type: .iconType) { [weak self] in
            self?.withdrawAction?()
        }
                                       .createView(parentStyle: parentStyle)
    }

    private func createMenuButton(parentStyle: ThemeStyle) -> some View {
        let iconName = "icon_list"
        let content = PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                            clip: .circle(background: .layer5, spacing: 16, borderColor: .layer6),
                                            size: CGSize(width: 36, height: 36),
                                            templateColor: .textPrimary)
        return PlatformButtonViewModel(content: content,
                                type: .iconType) { [weak self] in
            withAnimation(Animation.easeInOut) {
                self?.menuAction?()
            }
        }
         .createView(parentStyle: parentStyle)
    }
}

#if DEBUG
struct dydxSimpleUIMarketsHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketsHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketsHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketsHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
