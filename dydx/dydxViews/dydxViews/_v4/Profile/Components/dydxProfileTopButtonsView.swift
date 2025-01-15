//
//  dydxProfileTopButtonsView.swift
//  dydxUI
//
//  Created by Rui Huang on 14/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileTopButtonsViewModel: PlatformViewModel {
    @Published public var settingsAction: (() -> Void)?
    @Published public var alertsAction: (() -> Void)?
    @Published public var modeAction: (() -> Void)?
    @Published public var hasNewAlerts: Bool = false

    public lazy var toggleBinding = Binding<Bool> {
        return true
    } set: { _ in
        self.modeAction?()
    }

    public init() { }

    public static var previewValue: dydxProfileTopButtonsViewModel {
        let vm = dydxProfileTopButtonsViewModel()
        vm.hasNewAlerts = true
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 16) {
                HStack(spacing: 16) {
                    self.createButton(style: style,
                                      imageName: "icon_settings",
                                      badge: false,
                                      action: self.settingsAction)
                    .frame(maxWidth: .infinity)

                    self.createButton(style: style,
                                      imageName: "icon_alerts",
                                      badge: self.hasNewAlerts,
                                      action: self.alertsAction)
                    .frame(maxWidth: .infinity)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                self.createModeButton(style: style)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
                .frame(minHeight: 68)

            return AnyView(view)
        }
    }

    private func createModeButton(style: ThemeStyle) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("dYdX " + DataLocalizer.localize(path: "APP.TRADE.MODE.PRO"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)

                Text(DataLocalizer.localize(path: "APP.TRADE.MODE.FULLY_FEATURED"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
            }
            Toggle("", isOn: toggleBinding)
                .tint(ThemeColor.SemanticColor.colorPurple.color)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .themeColor(background: .layer3)
        .cornerRadius(12, corners: .allCorners)
    }

    private func createButton(style: ThemeStyle, imageName: String, badge: Bool, action: (() -> Void)?) -> some View {
        let content = ZStack {
            PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                  clip: .noClip,
                                  size: CGSize(width: 24, height: 24),
                                  templateColor: .textTertiary)
            .createView(parentStyle: style)
            .padding(.horizontal, 16)

            if badge {
                Circle()
                    .fill(ThemeColor.SemanticColor.colorPurple.color)
                    .frame(width: 10, height: 10)
                    .padding(12)
                    .rightAligned()
                    .topAligned()
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)

        return PlatformButtonViewModel(content: content.wrappedViewModel,
                                       type: .iconType) {
            action?()
        }
        .createView(parentStyle: style)
    }
}

#if DEBUG
struct dydxProfileTopButtonsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileTopButtonsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileTopButtonsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileTopButtonsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
