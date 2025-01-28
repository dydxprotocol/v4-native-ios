//
//  dydxAppModeView.swift
//  dydxUI
//
//  Created by Rui Huang on 17/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public enum AppMode: String {
    case simple
    case pro
}

public class dydxAppModeViewModel: PlatformViewModel {
    @Published public var appMode: AppMode?
    @Published public var onChange: ((AppMode) -> Void)?
    @Published public var onCancel: (() -> Void)?

    private var buttonState: PlatformButtonState {
        if appMode != nil {
            return .primary
        } else {
            return .disabled
        }
    }

    public init() { }

    public static var previewValue: dydxAppModeViewModel {
        let vm = dydxAppModeViewModel()
        vm.appMode = .simple
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SELECT_MODE"))
                        .themeFont(fontType: .plus, fontSize: .largest)
                        .themeColor(foreground: .textPrimary)

                    Text(DataLocalizer.localize(path: "APP.TRADE.MODE.CHANGE_SETINGS"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .leftAligned()

                Button(action: { [weak self] in
                    self?.onChange?(.simple)
                }) {
                    VStack(spacing: 16) {
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SIMPLE"))
                                .themeFont(fontSize: .large)
                                .themeColor(foreground: .textPrimary)

                            Spacer()

                            Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SIMPLE_AND_EASIER"))
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textTertiary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .themeColor(background: .layer4)

                        Image("mode_simple", bundle: Bundle.dydxView)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .gradientShade(backgroundColor: .layer5, height: 64)
                    }
                }
                .themeColor(background: .layer5)
                .cornerRadius(24)

                Button(action: { [weak self] in
                    self?.onChange?(.pro)
                }) {
                    VStack(spacing: 16) {
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.TRADE.MODE.PRO"))
                                .themeFont(fontSize: .large)
                                .themeColor(foreground: .textPrimary)

                            Spacer()

                            Text(DataLocalizer.localize(path: "APP.TRADE.MODE.FULLY_FEATURED"))
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textTertiary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .themeColor(background: .layer4)

                        Image("mode_pro", bundle: Bundle.dydxView)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .gradientShade(backgroundColor: .layer5, height: 64)
                    }
                }
                .themeColor(background: .layer5)
                .cornerRadius(24)
            }
                .padding([.leading, .trailing])
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxAppModeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAppModeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAppModeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAppModeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
