//
//  dydxSettingsHelpRowView.swift
//  dydxViews
//
//  Created by Michael Maguire on 11/9/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSettingsSecondaryActionsViewModel: PlatformViewModel {
    @Published public var settingsAction: (() -> Void)?
    @Published public var helpAction: (() -> Void)?
    @Published public var alertsAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSettingsSecondaryActionsViewModel {
        let vm = dydxSettingsSecondaryActionsViewModel()
        return vm
    }
    
    private var settingsHelpRow: some View {
        HStack(spacing: 16) {
            self.createButton(imageName: "icon_settings",
                              title: DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.SETTINGS"),
                              action: self.settingsAction)
            
            self.createButton(imageName: "icon_tutorial",
                              title: DataLocalizer.localize(path: "APP.HEADER.HELP"),
                              action: self.helpAction)
        }
    }
    
    private var alertsRow: some View {
        self.createButton(imageName: "icon_alerts",
                          title: DataLocalizer.localize(path: "APP.GENERAL.ALERTS"),
                          action: self.alertsAction)
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 16) {
                    self.settingsHelpRow
                    self.alertsRow
                }
            )
        }
    }

    private func createButton(imageName: String, title: String, action: (() -> Void)?) -> some View {
        HStack(spacing: 8) {
            PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                  clip: .noClip,
                                  size: CGSize(width: 24, height: 24),
                                  templateColor: .textTertiary)
            .createView()

            Text(title)
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
        .themeColor(background: .layer3)
        .cornerRadius(12, corners: .allCorners)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            action?()
        }
    }
}

#if DEBUG
struct dydxSettingsSecondaryActionsViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSettingsSecondaryActionsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSettingsSecondaryActionsViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSettingsSecondaryActionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
