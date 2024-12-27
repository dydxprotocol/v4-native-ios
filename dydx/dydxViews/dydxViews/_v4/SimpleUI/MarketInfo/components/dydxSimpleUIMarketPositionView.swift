//
//  dydxSimpleUIMarketPositionView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketPositionViewModel: PlatformViewModel {
    @Published public var closeAction: (() -> Void)?
    @Published public var shareAction: (() -> Void)?
    @Published public var unrealizedPNLAmount: SignedAmountViewModel?
    @Published public var entryPrice: String?
    @Published public var side: SideTextViewModel?
    @Published public var size: String?
    @Published public var amount: String?
    @Published public var logoUrl: URL?
    @Published public var funding: SignedAmountViewModel?
    @Published public var liquidationPrice: String?
    @Published public var symbol: String?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketPositionViewModel {
        let vm = dydxSimpleUIMarketPositionViewModel()
        vm.closeAction = {}
        vm.unrealizedPNLAmount = .previewValue
        vm.side = .previewValue
        vm.entryPrice = "$120.00"
        vm.size = "0.0012"
        vm.amount = "$120.00"
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.funding = .previewValue
        vm.liquidationPrice = "$120.00"
        vm.symbol = "USD"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self, self.side != nil else { return AnyView(PlatformView.nilView) }

            return AnyView(
                self.createContent(style: style)
                    .sectionHeader {
                        self.createHeader(style: style)
                    }
            )
        }
    }

    private func createContent(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            DividerModel().createView(parentStyle: style)

            HStack {
                let amountHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: symbol ?? "-")
                        .createView(parentStyle: style.themeFont(fontSize: .smaller))
                }
                createCollectionItem(parentStyle: style,
                                     titleViewModel: amountHeader.wrappedViewModel,
                                     value: size)
                .frame(minWidth: 0, maxWidth: .infinity)

                let sizeHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD")
                        .createView(parentStyle: style.themeFont(fontSize: .smaller))
                }
                createCollectionItem(parentStyle: style,
                                     titleViewModel: sizeHeader.wrappedViewModel,
                                     value: amount)
                .frame(minWidth: 0, maxWidth: .infinity)

                createCollectionItem(parentStyle: style,
                                     title: DataLocalizer.localize(path: "APP.SHARE_ACTIVITY_MODAL.PROFIT"),
                                     valueViewModel: unrealizedPNLAmount)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)

            DividerModel().createView(parentStyle: style)

            HStack {
                createCollectionItem(parentStyle: style,
                                     title: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"),
                                     valueViewModel: funding)
                .frame(minWidth: 0, maxWidth: .infinity)

                createCollectionItem(parentStyle: style,
                                     title: DataLocalizer.localize(path: "APP.GENERAL.AVG_ENTRY"),
                                     value: entryPrice)
                .frame(minWidth: 0, maxWidth: .infinity)

                createCollectionItem(parentStyle: style,
                                     title: DataLocalizer.localize(path: "APP.TRADE.LIQUIDATION_PRICE_SHORT"),
                                     value: liquidationPrice)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)

            DividerModel().createView(parentStyle: style)

        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, title: String?, valueViewModel: PlatformViewModel?) -> some View {
        let titleViewModel = Text(title ?? "")
            .themeFont(fontType: .plus, fontSize: .small)
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
        return createCollectionItem(parentStyle: parentStyle, titleViewModel: titleViewModel, valueViewModel: valueViewModel)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, titleViewModel: PlatformViewModel?, value: String?) -> some View {
        let valueViewModel = Text(value ?? "-")
            .themeFont(fontSize: .large)
            .themeColor(foreground: .textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
           // .fixedSize(horizontal: true, vertical: false)
            .leftAligned()
            .wrappedViewModel
        return createCollectionItem(parentStyle: parentStyle, titleViewModel: titleViewModel, valueViewModel: valueViewModel)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, title: String?, value: String?) -> some View {
        let titleViewModel = Text(title ?? "")
            .themeFont(fontType: .plus, fontSize: .small)
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
        let valueViewModel = Text(value ?? "-")
            .themeFont(fontSize: .large)
            .themeColor(foreground: .textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
          //  .fixedSize(horizontal: true, vertical: false)
            .leftAligned()
            .wrappedViewModel
        return createCollectionItem(parentStyle: parentStyle, titleViewModel: titleViewModel, valueViewModel: valueViewModel)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, titleViewModel: PlatformViewModel?, valueViewModel: PlatformViewModel?) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                titleViewModel?.createView(parentStyle: parentStyle)
                valueViewModel?.createView(parentStyle: parentStyle, styleKey: nil)
            }
            Spacer()
        }
        .leftAligned()
    }

    private func createHeader(style: ThemeStyle) -> some View {
        VStack {
            HStack {
                Text(DataLocalizer.localize(path: "APP.GENERAL.POSITION"))
                    .themeFont(fontType: .plus, fontSize: .largest)
                    .padding(.leading, 16)

                self.side?.createView(parentStyle: style)

                Spacer()

                Button(action: self.closeAction ?? {}) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.CLOSE"))
                        .themeColor(foreground: .colorRed)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding([.bottom, .top], 4)
                .padding([.leading, .trailing], 12)
                .themeColor(background: .colorFadedRed)
                .clipShape(Capsule())
            }
            .padding(.trailing, 16)

            Spacer(minLength: 24)
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketPositionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketPositionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketPositionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketPositionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
