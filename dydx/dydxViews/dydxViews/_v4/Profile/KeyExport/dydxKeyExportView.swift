//
//  dydxKeyExportView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/22/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import RoutingKit

public class dydxKeyExportViewModel: PlatformViewModel {
    public enum State {
        case warning, noRevealed, revealed
    }
    @Published public var state: State = .warning
    @Published public var copyAction: (() -> Void)?
    @Published public var phrase: String?

    public init() { }

    public static var previewValue: dydxKeyExportViewModel {
        let vm = dydxKeyExportViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view =
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.REVEAL_SECRET_PHRASE"))
                            .themeFont(fontType: .plus, fontSize: .largest)
                            .themeColor(foreground: .textPrimary)

                        Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.REVEAL_SECRET_PHRASE_DESCRIPTION"))
                            .themeFont(fontSize: .medium)
                    }

                    HStack {
                        PlatformIconViewModel(type: .asset(name: "icon_keyexport_warning", bundle: Bundle.dydxView))
                            .createView(parentStyle: style)
                        Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.SECRET_PHRASE_RISK"))
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textPrimary)
                    }
                    .padding(.vertical, 20)

                    Spacer()

                    VStack(spacing: -8) {
                        self.createDisplayContent(parentStyle: style)
                        .padding()
                        .padding(.bottom, 12)
                        .frame(minHeight: 180, maxHeight: 220)
                        .frame(maxWidth: .infinity)
                        .themeColor(background: .layer0)
                        .cornerRadius(12, corners: [.topLeft, .topRight])

                        self.createCtaButton(parentStyle: style)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, self.safeAreaInsets?.bottom)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createDisplayContent(parentStyle: ThemeStyle) -> some View {
        Group {
            switch state {
            case .warning:
                VStack(alignment: .leading, spacing: 16) {
                    Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.BEFORE_PROCEED"))
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textPrimary)
                    Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.BEFORE_PROCEED_ACK"))
                        .themeFont(fontSize: .medium)
                    Spacer()
                }

            case .noRevealed:
                ZStack {
                    VStack {
                        Text(phrase ?? "")
                            .themeFont(fontSize: .medium)
                        Spacer()
                    }
                    .blur(radius: 24)

                    VStack {
                        Spacer()
                        Text(DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.TAP_TO_REVEAL"))
                            .themeFont(fontSize: .medium)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 2)) { [weak self] in
                                    self?.state = .revealed
                                }
                            }
                    }
                }

            case .revealed:
                VStack {
                    Text(phrase ?? "")
                        .themeFont(fontSize: .medium)
                    Spacer()
                }
            }
        }
    }

    private func createCtaButton(parentStyle: ThemeStyle) -> some View {
        let buttonContent =
            Text(ctaText)
                .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent) { [weak self] in
            switch self?.state {
            case .warning:
                self?.state = .noRevealed
            case .noRevealed, .revealed:
                self?.copyAction?()
            case .none:
                break
            }
        }
           .createView(parentStyle: parentStyle)
           .animation(.easeInOut(duration: 0.1))
    }

    private var ctaText: String {
        switch state {
        case .warning:
            return DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.I_UNDERSTAND")
        case .noRevealed, .revealed:
            return DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.COPY_TO_CLIPBOARD")
        }
    }

    private var footerText: String {
        switch state {
        case .warning:
            return DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.SAFE_PLACE")
        case .noRevealed, .revealed:
            return DataLocalizer.localize(path: "APP.MNEMONIC_EXPORT.DONT_SHOW")
        }
    }
}

#if DEBUG
struct dydxKeyExportView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxKeyExportViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxKeyExportView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxKeyExportViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
