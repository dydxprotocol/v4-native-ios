//
//  dydxSimpleUIMenuButtonsView.swift
//  dydxUI
//
//  Created by Rui Huang on 21/04/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMenuButtonsViewModel: PlatformViewModel {
    @Published public var depositAction: (() -> Void)?
    @Published public var transferAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMenuButtonsViewModel {
        let vm = dydxSimpleUIMenuButtonsViewModel()
        vm.transferAction = { }
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 16) {
                if self.depositAction != nil {
                    self.createDepositButton(parentStyle: style)
                }
                if self.transferAction != nil {
                    self.createTransferButton(parentStyle: style)
                }
            }
            return AnyView(view)
        }
    }

    private func createDepositButton(parentStyle: ThemeStyle) -> some View {
        let iconName = "icon_transfer_deposit_2"
        let content = HStack {
            PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                  size: CGSize(width: 20, height: 20),
                                  templateColor: .colorWhite)
            .createView(parentStyle: parentStyle)

            Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                .themeColor(foreground: .colorWhite)
        }
            .wrappedViewModel

        return PlatformButtonViewModel(content: content,
                                       type: .defaultType(cornerRadius: 16)) { [weak self] in
            self?.depositAction?()
        }
                                       .createView(parentStyle: parentStyle)
    }

    private func createTransferButton(parentStyle: ThemeStyle) -> some View {
        let iconName = "icon_swap_vertical"
        let content =
            PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                  size: CGSize(width: 20, height: 20),
                                  templateColor: .textPrimary)

        return PlatformButtonViewModel(content: content,
                                       type: .defaultType(fillWidth: false, backgroundColor: .layer3, cornerRadius: 16),
                                       state: .none) { [weak self] in
            self?.transferAction?()
        }
                                       .createView(parentStyle: parentStyle)
    }
}

#if DEBUG
struct dydxSimpleUIMenuButtonsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMenuButtonsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMenuButtonsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMenuButtonsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
