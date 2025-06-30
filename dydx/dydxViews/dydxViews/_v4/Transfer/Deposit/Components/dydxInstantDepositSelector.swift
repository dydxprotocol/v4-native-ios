//
//  dydxInstantDepositSelector.swift
//  dydxUI
//
//  Created by Rui Huang on 21/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public enum TransferRouteSelection {
    case instant, regular
}

public enum DepositSelectorViewStyle {
    case toggle, display_only
}

public class dydxInstantDepositSelectorModel: PlatformViewModel {
    @Published public var uiStyle = DepositSelectorViewStyle.display_only
    @Published public var selection: TransferRouteSelection = .regular
    @Published public var instantFee: String?
    @Published public var regularTime: String?
    @Published public var regularFee: String?
    @Published public var selectionAction: ((TransferRouteSelection) -> Void)?

    public init() { }

    public static var previewValue: dydxInstantDepositSelectorModel {
        let vm = dydxInstantDepositSelectorModel()
        vm.instantFee = "$0.01"
        vm.regularTime = "$0.02"
        vm.regularFee = "$1.00"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                switch self.uiStyle {
                case .toggle:
                    HStack(spacing: 16) {
                        Button(action: {
                            self.selectionAction?(.instant)
                        }) {
                            self.instantSelectView(style: style)
                                .frame(maxWidth: .infinity)
                        }
                        Button(action: {
                            self.selectionAction?(.regular)
                        }) {
                            self.regularSelectView(style: style)
                                .frame(maxWidth: .infinity)
                        }
                    }
                case .display_only:
                    self.displayView(style: style)
                }
            }
            return AnyView(view)
        }
    }

    private func displayView(style: ThemeStyle) -> some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.DEPOSIT_METHOD"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)

            Spacer()

            switch self.selection {
            case .instant:
                HStack(spacing: 4) {
                    PlatformIconViewModel(type: .asset(name: "icon_instant_deposit", bundle: Bundle.dydxView),
                                          clip: .noClip,
                                          size: CGSize(width: 14, height: 14),
                                          templateColor: .colorYellow)
                    .createView(parentStyle: style)

                    Text(DataLocalizer.localize(path: "APP.GENERAL.INSTANT"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textPrimary)

                    Text(DataLocalizer.localize(path: "APP.GENERAL.FREE"))
                        .themeFont(fontSize: .smallest)
                        .themeColor(foreground: .colorPurple)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .themeColor(background: .colorFadedPurple)
                        .cornerRadius(6, corners: .allCorners)
                }
            case .regular:
                HStack(spacing: 4) {
                    Text(regularTime ?? "-")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textSecondary)
                }
            }
        }
    }

    private func instantSelectView(style: ThemeStyle) -> some View {
        let selected = selection == .instant
        return HStack {
            PlatformIconViewModel(type: .asset(name: "icon_instant_deposit", bundle: Bundle.dydxView),
                                  clip: .noClip,
                                  size: CGSize(width: 20, height: 20),
                                  templateColor: selected ? .colorYellow : .textTertiary)
            .createView(parentStyle: style)

            VStack(alignment: .leading) {
                Text(DataLocalizer.localize(path: "APP.GENERAL.INSTANT"))
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: selected ? .textPrimary : .textTertiary)
                Text(instantFee ?? "")
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: selected ? .textSecondary : .textTertiary)
            }

            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .themeColor(background: selected ? .layer2 : .layer4)
        .cornerRadius(16, corners: .allCorners)
        .if(selected) { view in
            view.borderAndClip(style: .cornerRadius(16), borderColor: .colorPurple, lineWidth: 2)
        }
    }

    private func regularSelectView(style: ThemeStyle) -> some View {
        let selected = selection == .regular
        return HStack {
            PlatformIconViewModel(type: .asset(name: "icon_regular_deposit", bundle: Bundle.dydxView),
                                  clip: .noClip,
                                  size: CGSize(width: 20, height: 20),
                                  templateColor: selected ? .colorPurple : .textTertiary)
            .createView(parentStyle: style)

            VStack(alignment: .leading) {
                Text(regularTime ?? "")
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: selected ? .textPrimary : .textTertiary)
               Text(regularFee ?? "")
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: selected ? .textSecondary : .textTertiary)
           }

            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .themeColor(background: selected ? .layer2 : .layer4)
        .cornerRadius(16, corners: .allCorners)
        .if(selected) { view in
            view.borderAndClip(style: .cornerRadius(16), borderColor: .colorPurple, lineWidth: 2)
        }
    }
}

#if DEBUG
struct dydxInstantDepositSelector_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositSelectorModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxInstantDepositSelector_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositSelectorModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
