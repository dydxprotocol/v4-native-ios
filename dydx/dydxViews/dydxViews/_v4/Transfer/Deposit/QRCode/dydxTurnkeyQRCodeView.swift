//
//  dydxTurnkeyQRCodeView.swift
//  dydxUI
//
//  Created by Rui Huang on 06/08/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import EFQRCode

public class dydxTurnkeyQRCodeViewModel: PlatformViewModel {
    @Published public var cancelAction: (() -> Void)?
    @Published public var subtitle: String?
    @Published public var footer: String?
    @Published public var address: String?
    @Published public var chainIcon: URL?
    @Published public var onCopyAction: (() -> Void)?
    @Published public var copied: Bool = false

    public init() { }

    public static var previewValue: dydxTurnkeyQRCodeViewModel {
        let vm = dydxTurnkeyQRCodeViewModel()
        vm.subtitle = "Subtitle"
        vm.footer = "Footer"
        vm.address = "0xdeadbeef"
        vm.chainIcon = URL(string: "https://v4.testnet.dydx.exchange/chains/ethereum.png")
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 24) {
                HStack {
                    ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                        .createView(parentStyle: style)

                    Spacer()
                }
                .padding(.top, 24)

                // ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .larger)

                        Text(self.subtitle ?? "")
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .medium)
                    }
                    .padding(.horizontal, 8)

                    self.createQRCodeSection(style: style)

                    if let address = self.address {
                        self.createAddressSection(style: style, address: address)
                    }
                    Spacer()

                    if let footer = self.footer {
                        ValidationErrorViewModel(state: .warning,
                                                 message: footer)
                        .createView(parentStyle: style)
                    }
                }
            }
                .padding(.horizontal, 24)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer2)
                .ignoresSafeArea(edges: [.bottom])

            return AnyView(view)
        }
    }

    private func createQRCodeSection(style: ThemeStyle) -> some View {
        HStack {
            HStack {
                PlatformIconViewModel(type: .url(url: self.chainIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 36, height: 36))
                    .createView(parentStyle: style)
                    .padding(16)
                    .topAligned()
                    .leftAligned()
            }
            .frame(maxWidth: .infinity)

            HStack {
                let icon = UIImage(named: "icon_dydx", in: Bundle.dydxView, compatibleWith: nil)
                if let address = self.address, let cgImage = EFQRCode.generate(for: address, backgroundColor: ThemeColor.SemanticColor.layer2.color.cgColor!, foregroundColor: ThemeColor.SemanticColor.textPrimary.color.cgColor!, icon: icon?.cgImage, pointStyle: .circle, isTimingPointStyled: true) {
                    let uiImage = UIImage(cgImage: cgImage)
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 8)
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: (UIScreen.main.bounds.width - 24 * 2) / 2)
        .border(borderWidth: 1, cornerRadius: 8, borderColor: ThemeColor.SemanticColor.borderDefault.color)
    }

    private func createAddressSection(style: ThemeStyle, address: String) -> some View {
        HStack {
            let highlightedAddress = self.highlightEnds(from: address, color: ThemeColor.SemanticColor.textPrimary.color)
            Text(highlightedAddress)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .small)
                .frame(maxWidth: .infinity)

            if self.copied {
                let buttonContent = HStack {
                    PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: Bundle.dydxView),
                                          size: CGSize(width: 16, height: 16),
                                          templateColor: .colorGreen)
                    .createView(parentStyle: style)
                    Text(DataLocalizer.localize(path: "APP.GENERAL.COPIED"))
                        .themeColor(foreground: .colorGreen)
                }
                PlatformButtonViewModel(content: buttonContent.wrappedViewModel,
                                        type: .defaultType(backgroundColor: .colorFadedGreen, cornerRadius: 16),
                                        state: .none) { [weak self] in
                    self?.onCopyAction?()
                }
                                        .createView(parentStyle: style)
                                        .frame(maxWidth: .infinity)
            } else {
                let buttonContent = HStack {
                    PlatformIconViewModel(type: .asset(name: "icon_copy", bundle: Bundle.dydxView),
                                          size: CGSize(width: 16, height: 16),
                                          templateColor: .textPrimary)
                    .createView(parentStyle: style)
                    Text(DataLocalizer.localize(path: "APP.GENERAL.COPY"))
                }
                PlatformButtonViewModel(content: buttonContent.wrappedViewModel,
                                        type: .defaultType(cornerRadius: 16),
                                        state: .primary) { [weak self] in
                    self?.onCopyAction?()
                }
                                        .createView(parentStyle: style)
                                        .frame(maxWidth: .infinity)
            }
        }
    }

    private func highlightEnds(from input: String, color: Color) -> AttributedString {
        var attributed = AttributedString(input)

        let length = input.count

        guard length >= 6 else {
            // If the string is shorter than 6 characters, highlight the whole thing
            attributed.foregroundColor = color
            return attributed
        }

        // First 6 characters
        if let startRange = attributed.range(of: String(input.prefix(6))) {
            attributed[startRange].foregroundColor = color
        }

        // Last 6 characters
        if let endRange = attributed.range(of: String(input.suffix(6)), options: .backwards) {
            attributed[endRange].foregroundColor = color
        }

        return attributed
    }
}

#if DEBUG
struct dydxTurnkeyQRCodeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTurnkeyQRCodeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTurnkeyQRCodeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTurnkeyQRCodeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
