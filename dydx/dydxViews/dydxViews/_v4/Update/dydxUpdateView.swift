//
//  dydxUpdateView.swift
//  dydxViews
//
//  Created by John Huang on 10/24/23.
//

import Foundation

import LocalAuthentication
import PlatformUI
import SwiftUI
import Utilities

public class dydxUpdateViewModel: PlatformViewModel {
    @Published public var updateTapped: (() -> Void)?
    @Published public var title: String?
    @Published public var text: String?
    @Published public var action: String?

    public static var previewValue: dydxUpdateViewModel {
        let vm = dydxUpdateViewModel()
        vm.title = "Title"
        vm.text = "text"
        vm.action = "Action"
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    self.logoImage(parentStyle: parentStyle, styleKey: styleKey)
                    Spacer()
                    VStack(spacing: 32) {
                        self.titleLabel()
                        self.textLabel()
                        self.updateButton(parentStyle: parentStyle, styleKey: styleKey)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .themeColor(background: .layer2)
            )
        }
    }

    private func titleLabel() -> Text? {
        guard let title = title else {
            return nil
        }
        return Text(title)
            .themeFont(fontType: .text, fontSize: .large)
            .themeColor(foreground: .textPrimary)
    }

    private func textLabel() -> Text? {
        guard let text = text else {
            return nil
        }
        return Text(text)
            .themeFont(fontType: .text, fontSize: .medium)
            .themeColor(foreground: .textSecondary)
    }

    private func updateButton(parentStyle: ThemeStyle, styleKey: String?) -> PlatformView? {
        guard let action = action else {
            return nil
        }
        let content = HStack {
            Spacer()
            Text(action)
            Spacer()
        }
        .wrappedViewModel

        return PlatformButtonViewModel(content: content) { [weak self] in
            self?.updateTapped?()
        }
        .createView(parentStyle: parentStyle, styleKey: styleKey)
    }

    private func logoImage(parentStyle: ThemeStyle, styleKey: String?) -> PlatformView {
        let imageName: String
        if currentThemeType == .light {
            imageName = "brand_light"
        } else {
            imageName = "brand_dark"
        }
        return PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                     clip: .noClip,
                                     size: .init(width: 100, height: 100),
                                     templateColor: nil)
            .createView(parentStyle: parentStyle, styleKey: styleKey)
    }
}

#if DEBUG
    struct dydxUpdateViewModel_Previews_Dark: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyDarkTheme()
            ThemeSettings.applyStyles()
            return dydxUpdateViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }

    struct dydxUpdateViewModel_Previews_Light: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyLightTheme()
            ThemeSettings.applyStyles()
            return dydxUpdateViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
