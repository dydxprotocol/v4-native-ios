//
//  dydxTransferNobleAddressView.swift
//  dydxUI
//
//  Created by Rui Huang on 14/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import EFQRCode

public class dydxTransferNobleAddressViewModel: PlatformViewModel {
    @Published public var cancelAction: (() -> Void)?
    @Published public var copyAction: (() -> Void)?
    @Published public var address: String?

    public init() { }

    public static var previewValue: dydxTransferNobleAddressViewModel {
        let vm = dydxTransferNobleAddressViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                HStack {
                    ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                        .createView(parentStyle: style)

                    Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .larger)
                        .centerAligned()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(height: 54)

                DividerModel().createView(parentStyle: style)

                GeometryReader { geo in
                    VStack(alignment: .center, spacing: 16) {
                        Text(self.text_1)
                            .multilineTextAlignment(.center)

                        let icon = UIImage(named: "icon_noble", in: Bundle.dydxView, compatibleWith: nil)
                        if let address = self.address, let cgImage = EFQRCode.generate(for: address, backgroundColor: ThemeColor.SemanticColor.layer1.color.cgColor!, foregroundColor: ThemeColor.SemanticColor.textPrimary.color.cgColor!, icon: icon?.cgImage, pointStyle: .circle, isTimingPointStyled: true) {
                            let uiImage = UIImage(cgImage: cgImage)
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.horizontal, geo.size.width / 6)
                            Spacer()
                        } else {
                            Spacer()
                        }

                        if let address = self.address {
                            VStack {
                                Text(DataLocalizer.localize(path: "APP.ONBOARDING.YOUR_NOBLE_ADDRESS"))
                                    .themeColor(foreground: .textTertiary)
                                    .themeFont(fontSize: .medium)

                                HStack(spacing: 16) {
                                    Text(address)
                                        .themeColor(foreground: .textPrimary)
                                        .themeFont(fontSize: .large)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)

                                    Button(action: self.copyAction ?? {},
                                           label: {
                                        PlatformIconViewModel(type: .asset(name: "icon_copy", bundle: Bundle.dydxView),
                                                              size: CGSize(width: 16, height: 16),
                                                              templateColor: .textPrimary)
                                        .createView(parentStyle: style)
                                    })
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .themeColor(background: .layer3)
                                .cornerRadius(16, corners: .allCorners)
                            }
                        }

                        HStack {
                            PlatformIconViewModel(type: .asset(name: "icon_warning", bundle: Bundle.dydxView),
                                                  size: CGSize(width: 16, height: 16),
                                                  templateColor: .colorYellow)
                            .createView(parentStyle: style)

                            Text(DataLocalizer.localize(path: "WARNINGS.ONBOARDING.NOBLE_CHAIN_ONLY"))
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .colorYellow)
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding([.leading, .trailing])

                PlatformButtonViewModel(content: Text(DataLocalizer.localize(path: "APP.ONBOARDING.COPY_NOBLE")).wrappedViewModel,
                                        type: .defaultType(minHeight: 56, cornerRadius: 16),
                                        state: .primary,
                                        action: self.copyAction ?? {})
                    .createView(parentStyle: parentStyle)
                    .padding([.leading, .trailing])
                    .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))

            }
                .themeColor(background: .layer1)

            return AnyView(view.ignoresSafeArea(edges: [.all]))
        }
    }

    private var text_1: AttributedString {
        let aprText = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.TO_DEPOSIT_FROM_CEX")
        var result = AttributedString(aprText)
            .themeFont(fontType: .base, fontSize: .medium)
            .themeColor(foreground: .textTertiary, to: nil)

        if let range = result.range(of: "{ASSET}") {
            result.replaceSubrange(range, with: AttributedString("USDC").themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium))
        }
        if let range = result.range(of: "{NETWORK}") {
            result.replaceSubrange(range, with: AttributedString("Noble Network").themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium))
        }
        return result
    }
}

#if DEBUG
struct dydxTransferNobleAddressView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferNobleAddressViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferNobleAddressView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferNobleAddressViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
