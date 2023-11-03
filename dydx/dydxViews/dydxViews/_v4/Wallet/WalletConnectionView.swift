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

    public init() {}

    public static var previewValue: WalletConnectionViewModel = {
        let vm = WalletConnectionViewModel()
        vm.walletAddress = "0xAA...AAAA"
        vm.walletImageUrl = URL(string: "https://s3.amazonaws.com/dydx.exchange/logos/walletconnect/lg/9d373b43ad4d2cf190fb1a774ec964a1addf406d6fd24af94ab7596e58c291b2.jpeg")
        vm.equity = "$1234.50"
        vm.pnl24hPercent = SignedAmountViewModel(text: "12%", sign: .plus)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {

        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            AnyView(
                Group {
                    let icon = PlatformIconViewModel(type: .url(url: self?.walletImageUrl), clip: .defaultCircle)
                        .createView(parentStyle: style)
                    let status = PlatformIconViewModel(type: .asset(name: "status_filled", bundle: Bundle.dydxView),
                                              size: CGSize(width: 8, height: 8),
                                              templateColor: self?.templateColor ?? .textTertiary)
                        .createView(parentStyle: style)

                    let main =
                        Text(self?.walletAddress ?? "")
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textPrimary)

                    let trailing =
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(self?.equity ?? "")
                                .themeFont(fontType: .number, fontSize: .small)
                            if let pnl24hPercent = self?.pnl24hPercent {
                                HStack {
                                    Text(DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.24H", params: nil))
                                       .themeFont(fontSize: .smaller)
                                    pnl24hPercent.createView(parentStyle: style
                                        .themeColor(foreground: .textTertiary)
                                        .themeFont(fontType: .number, fontSize: .smaller))
                                }
                            }
                        }

                    Group {
                        PlatformTableViewCellViewModel(leading: status.wrappedViewModel,
                                                       logo: icon.wrappedViewModel,
                                                       main: main.wrappedViewModel,
                                                       trailing: trailing.wrappedViewModel)
                            .createView(parentStyle: style)
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 64)
                    .themeColor(background: .layer5)
                    .cornerRadius(16)
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
