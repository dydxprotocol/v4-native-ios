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

    @Published public var tpSlGroupViewModel: dydxMarketTpSlGroupViewModel?
    @Published public var hasPosition: Bool = true

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
            guard let self = self  else { return AnyView(PlatformView.nilView) }

            return AnyView(
                self.createContent(style: style)
                    .sectionHeader {
                        self.createHeader(style: style)
                            .themeColor(background: .layer1)
                    }
            )
        }
    }

    private func createContent(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                let amountHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: symbol ?? "-")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: amountHeader.wrappedViewModel,
                                                        value: size)
                .frame(minWidth: 0, maxWidth: .infinity)

                let sizeHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: sizeHeader.wrappedViewModel,
                                                        value: amount)
                .frame(minWidth: 0, maxWidth: .infinity)

                let profitHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.SHARE_ACTIVITY_MODAL.PROFIT"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: profitHeader.wrappedViewModel,
                                                        valueViewModel: unrealizedPNLAmount)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)

            if self.hasPosition {
                HStack {
                    CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                            title: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"),
                                                            valueViewModel: funding)
                    .frame(minWidth: 0, maxWidth: .infinity)

                    CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                            title: DataLocalizer.localize(path: "APP.GENERAL.AVG_ENTRY"),
                                                            value: entryPrice)
                    .frame(minWidth: 0, maxWidth: .infinity)

                    CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                            title: DataLocalizer.localize(path: "APP.TRADE.LIQUIDATION_PRICE_SHORT"),
                                                            value: liquidationPrice)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)

                self.tpSlGroupViewModel?.createView(parentStyle: style)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private func createHeader(style: ThemeStyle) -> some View {
        VStack {
            HStack(alignment: .center) {
                Text(DataLocalizer.localize(path: "APP.GENERAL.POSITION"))
                    .themeFont(fontType: .plus, fontSize: .large)
                    .themeColor(foreground: .textPrimary)
                    .padding(.leading, 16)

                DividerModel().createView(parentStyle: style)

                self.side?.createView(parentStyle: style.themeFont(fontSize: .small))

                Spacer()

                if hasPosition {
                    let content = Text(DataLocalizer.localize(path: "APP.TRADE.CLOSE_POSITION"))
                        .themeColor(foreground: .colorRed)
                        .themeFont(fontSize: .small)
                        .wrappedViewModel

                    Button(action: { [weak self] in
                            self?.closeAction?()
                    }) {
                        content.createView(parentStyle: style)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding([.bottom, .top], 8)
                    .padding([.leading, .trailing], 12)
                    .themeColor(background: .layer3)
                    .clipShape(Capsule())
                }
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
