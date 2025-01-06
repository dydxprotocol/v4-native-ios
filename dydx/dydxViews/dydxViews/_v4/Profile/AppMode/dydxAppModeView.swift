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
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SELECT_MODE"))
                        .themeFont(fontType: .plus, fontSize: .largest)

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
                    HStack(spacing: 16) {
                        if self.appMode == .simple {
                            PlatformIconViewModel.selectedCheckmark
                                .createView(parentStyle: style)
                        } else {
                            PlatformIconViewModel.unselectedCheckmark
                                .createView(parentStyle: style)
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SIMPLE"))
                                    .themeFont(fontSize: .large)
                                    .themeColor(foreground: .textSecondary)

                                Spacer()

                                Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SIMPLE_AND_EASIER"))
                                    .themeFont(fontSize: .small)
                                    .themeColor(foreground: .textTertiary)
                                    .lineLimit(1)
                            }

                            Image("mode_simple", bundle: Bundle.dydxView)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .themeColor(background: .layer5)
                .borderAndClip(style: .cornerRadius(12), borderColor: .layer7)

                Button(action: { [weak self] in
                    self?.onChange?(.pro)
                }) {
                    HStack(spacing: 16) {
                        if self.appMode == .pro {
                            PlatformIconViewModel.selectedCheckmark
                                .createView(parentStyle: style)
                        } else {
                            PlatformIconViewModel.unselectedCheckmark
                                .createView(parentStyle: style)
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text(DataLocalizer.localize(path: "APP.TRADE.MODE.PRO"))
                                    .themeFont(fontSize: .large)
                                    .themeColor(foreground: .textSecondary)

                                Spacer()

                                Text(DataLocalizer.localize(path: "APP.TRADE.MODE.FULLY_FEATURED"))
                                    .themeFont(fontSize: .small)
                                    .themeColor(foreground: .textTertiary)
                                    .lineLimit(1)
                            }

                            Image("mode_pro", bundle: Bundle.dydxView)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .themeColor(background: .layer5)
                .borderAndClip(style: .cornerRadius(12), borderColor: .layer7)

                let cancelText = Text(DataLocalizer.localize(path: "APP.GENERAL.OK", params: nil))
                PlatformButtonViewModel(content: cancelText.wrappedViewModel, state: self.buttonState) { [weak self] in
                    self?.onCancel?()
                }
                .createView(parentStyle: style)
            }
                .padding([.leading, .trailing])
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

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
