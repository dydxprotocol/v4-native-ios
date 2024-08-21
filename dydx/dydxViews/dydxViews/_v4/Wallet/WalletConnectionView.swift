//
//  WalletConnectionView.swift
//  dydxViews
//
//  Created by Rui Huang on 8/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class WalletConnectionViewModel: PlatformViewModel {
    @Published public var id = UUID()
    @Published public var walletAddress: String?
    @Published public var equity: String?
    @Published public var selected: Bool = true
    @Published public var walletImageUrl: URL?
    @Published public var pnl24hPercent: SignedAmountViewModel?
    @Published public var onTap: (() -> Void)?
    @Published public var openInEtherscanTapped: (() -> Void)?
    @Published public var exportSecretPhraseTapped: (() -> Void)?

    public init() {}

    public static var previewValue: WalletConnectionViewModel = {
        let vm = WalletConnectionViewModel()
        vm.walletAddress = "0xAA...AAAA"
        vm.walletImageUrl = URL(string: "https://s3.amazonaws.com/dydx.exchange/logos/walletconnect/lg/9d373b43ad4d2cf190fb1a774ec964a1addf406d6fd24af94ab7596e58c291b2.jpeg")
        vm.equity = "$1234.50"
        vm.pnl24hPercent = SignedAmountViewModel(text: "12%", sign: .plus, coloringOption: .allText)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {

        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            AnyView(
                Group {
                    let buttonBorderWidth = 1.5
                    let buttonContentVerticalPadding: CGFloat = 8
                    let buttonContentHorizontalPadding: CGFloat = 12

                    let icon = self?.walletImageUrl == nil ? nil : PlatformIconViewModel(type: .url(url: self?.walletImageUrl), clip: .defaultCircle)
                        .createView(parentStyle: style)
                    let status = PlatformIconViewModel(type: .asset(name: "status_filled", bundle: Bundle.dydxView),
                                                       size: CGSize(width: 8, height: 8),
                                                       templateColor: self?.templateColor ?? .textTertiary)
                        .createView(parentStyle: style)

                    let walletAddress = self?.walletAddress ?? ""
                    let addressText = Text(walletAddress)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textPrimary)

                    let blockExplorerButton = Button(action: {
                        self?.openInEtherscanTapped?()
                    }, label: {
                        HStack(spacing: 4) {
                            Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.BLOCK_EXPLORER", params: nil) ?? "")
                                .lineLimit(1)
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .textTertiary)
                            PlatformIconViewModel(type: .asset(name: "icon_external_link",
                                                               bundle: .dydxView),
                                                  clip: .noClip,
                                                  size: .init(width: 20, height: 20),
                                                  templateColor: .textTertiary)
                            .createView(parentStyle: style)
                        }
                        .fixedSize()
                        .padding(.horizontal, buttonContentHorizontalPadding)
                        .padding(.vertical, buttonContentVerticalPadding)
                        .themeColor(background: .layer3)
                    })
                        .borderAndClip(style: .cornerRadius(8), borderColor: .layer6, lineWidth: buttonBorderWidth)

                    let exportPhraseButton = Button(action: {
                        self?.exportSecretPhraseTapped?()
                    }, label: {
                        Text(DataLocalizer.shared?.localize(path: "APP.MNEMONIC_EXPORT.EXPORT_PHRASE", params: nil) ?? "")
                            .lineLimit(1)
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .colorRed)
                            .padding(.horizontal, buttonContentHorizontalPadding)
                            .padding(.vertical, buttonContentVerticalPadding)
                    })
                        .themeColor(background: .colorFadedRed)
                        .borderAndClip(style: .capsule, borderColor: .borderDestructive, lineWidth: buttonBorderWidth)

                    let main = VStack(alignment: .leading) {
                        addressText
                        if self?.selected == true &&
                            walletAddress.isNotEmpty && walletAddress.starts(with: "dydx") == false {
                            HStack(spacing: 10) {
                                blockExplorerButton
                                exportPhraseButton
                            }
                        }
                    }
                        .padding(.vertical, 16)

                    PlatformTableViewCellViewModel(leading: status.wrappedViewModel,
                                                   logo: icon?.wrappedViewModel,
                                                   main: main.wrappedViewModel)
                    .createView(parentStyle: style)
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .themeColor(background: self?.selected == true ? .layer1 : .layer3)
                    .borderAndClip(style: .cornerRadius(10), borderColor: .borderDefault, lineWidth: 1)
                    .onTapGesture {
                        self?.onTap?()
                    }
                }
            )
        }
    }

    private var templateColor: ThemeColor.SemanticColor {
        selected ? .colorGreen : .textTertiary
    }
}

#if DEBUG
struct WalletConnectionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return WalletConnectionViewModel.previewValue.createView()
            .previewLayout(.sizeThatFits)
    }
}

struct WalletConnectionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return WalletConnectionViewModel.previewValue.createView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
